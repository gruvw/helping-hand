use std::sync::Arc;
use std::sync::Mutex;
use std::time::Duration;

use esp_idf_svc::mdns::EspMdns;

use esp_idf_hal::delay::FreeRtos;
use esp_idf_hal::peripherals::Peripherals;
use esp_idf_svc::eventloop::EspSystemEventLoop;
use esp_idf_svc::http::server::Configuration as HttpConfiguration;
use esp_idf_svc::http::server::EspHttpServer;
use esp_idf_svc::http::Method;
use esp_idf_svc::ipv4::{
    Configuration as IpConfiguration, Ipv4Addr, Mask, RouterConfiguration, Subnet,
};
use esp_idf_svc::netif::{EspNetif, NetifConfiguration, NetifStack};
use esp_idf_svc::nvs::EspDefaultNvsPartition;
use esp_idf_svc::wifi::{
    AccessPointConfiguration, AuthMethod, Configuration as WifiConfiguration, EspWifi, WifiDriver,
};
use pwm_pca9685::Channel;

use helping_hand::servo::ServoManager;

const DEVICE_ID: &str = "0001";

const LOG_TAG: &str = "main";

fn main() -> ! {
    esp_idf_svc::sys::link_patches();
    esp_idf_svc::log::EspLogger::initialize_default();

    log::info!(target: LOG_TAG, "device started");

    let peripherals = Peripherals::take().expect("failed to take peripherals");
    let sm = ServoManager::new(
        peripherals.i2c0,
        peripherals.pins.gpio4, // SDA
        peripherals.pins.gpio5, // SCL
    );
    let sm = Arc::new(Mutex::new(sm));
    let sm_click = Arc::clone(&sm);

    log::info!(target: LOG_TAG, "device intitialized");

    let gateway = std::net::Ipv4Addr::new(192, 168, 1, 1);

    let ap_config = EspNetif::new_with_conf(&NetifConfiguration {
        ip_configuration: Some(IpConfiguration::Router(RouterConfiguration {
            subnet: Subnet {
                gateway: Ipv4Addr::from(gateway),
                mask: Mask(24),
            },
            dhcp_enabled: true,
            dns: None,
            secondary_dns: None,
        })),
        ..NetifConfiguration::wifi_default_router()
    })
    .expect("failed to create AP configuration");

    let sys_loop = EspSystemEventLoop::take().expect("failed to take event loop");
    let nvs = EspDefaultNvsPartition::take().expect("failed to take NVS partition");

    let driver = WifiDriver::new(peripherals.modem, sys_loop.clone(), Some(nvs))
        .expect("failed to create Wi-Fi driver");
    let sta_netif = EspNetif::new(NetifStack::Sta).expect("failed to create station netif");
    let mut wifi =
        EspWifi::wrap_all(driver, sta_netif, ap_config).expect("failed to wrap Wi-Fi config");

    wifi.set_configuration(&WifiConfiguration::AccessPoint(AccessPointConfiguration {
        ssid: "ESP32-Rust-Server".try_into().unwrap(),
        password: "rust-is-cool".try_into().unwrap(),
        auth_method: AuthMethod::WPA2WPA3Personal,
        ..Default::default()
    }))
    .expect("failed to set Wi-Fi config");
    wifi.start().expect("failed to start Wi-Fi");

    log::info!(target: LOG_TAG, "Wi-Fi AP started\ngateway: {}", gateway);

    let hostname = format!("hh-{}", DEVICE_ID);
    let mut mdns = EspMdns::take().expect("failed to take mDNS");
    mdns.set_hostname(&hostname)
        .expect("failed to set mDNS hostname");

    log::info!(target: LOG_TAG, "Set MDNS: {}.local", hostname);

    let mut server =
        EspHttpServer::new(&HttpConfiguration::default()).expect("failed to create HTTP server");

    server
        .fn_handler("/", Method::Get, |req| -> anyhow::Result<()> {
            let mut response = req.into_ok_response()?;
            response.write(b"Hello World!")?;
            Ok(())
        })
        .expect("failed to set home HTTP handler");

    server
        .fn_handler("/click", Method::Get, move |req| -> anyhow::Result<()> {
            let uri = req.uri();
            let query = uri.split_once('?').map(|(_, q)| q).unwrap_or("");

            let mut channel_nb: u8 = 0;
            let mut angle: f32 = 0.0;
            let mut duration_ms: u64 = 0;

            for pair in query.split('&') {
                if let Some((key, value)) = pair.split_once('=') {
                    match key {
                        "channel" => channel_nb = value.parse().unwrap_or(channel_nb),
                        "angle" => angle = value.parse().unwrap_or(angle),
                        "duration" => duration_ms = value.parse().unwrap_or(duration_ms),
                        _ => {
                            let mut response = req.into_response(400, Some("Bad Request"), &[])?;
                            response.write(b"invalid query parameter")?;
                            return Ok(());
                        }
                    }
                }
            }

            let channel = match channel_nb {
                0 => Channel::C0,
                1 => Channel::C1,
                2 => Channel::C2,
                3 => Channel::C3,
                4 => Channel::C4,
                5 => Channel::C5,
                _ => {
                    let mut response = req.into_response(400, Some("Bad Request"), &[])?;
                    response.write(b"invalid channel")?;
                    return Ok(());
                }
            };

            sm.lock()
                .expect("failed to acquire servo manager mutex")
                .click(channel, angle, Duration::from_millis(duration_ms));

            Ok(())
        })
        .expect("failed to set click HTTP handler");

    log::info!(target: LOG_TAG, "web server running");

    sm_click
        .lock()
        .expect("failed to acquire servo manager mutex")
        .click(Channel::C0, 25.0, Duration::from_millis(0));

    loop {
        FreeRtos::delay_ms(u32::MAX);
    }
}
