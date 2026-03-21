use esp_idf_hal::modem::Modem;
use esp_idf_svc::mdns::EspMdns;

use esp_idf_svc::eventloop::EspSystemEventLoop;
use esp_idf_svc::ipv4::{
    Configuration as IpConfiguration, Ipv4Addr, Mask, RouterConfiguration, Subnet,
};
use esp_idf_svc::netif::{EspNetif, NetifConfiguration, NetifStack};
use esp_idf_svc::nvs::EspDefaultNvsPartition;
use esp_idf_svc::wifi::{
    AccessPointConfiguration, AuthMethod, Configuration as WifiConfiguration, EspWifi, WifiDriver,
};

const DEVICE_ID: &str = env!("DEVICE_ID");

const LOG_TAG: &str = "network";

pub struct Network {
    _wifi: EspWifi<'static>,
    _mdns: EspMdns,
}

pub fn network_setup(modem: Modem<'static>) -> Network {
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

    let driver =
        WifiDriver::new(modem, sys_loop.clone(), Some(nvs)).expect("failed to create Wi-Fi driver");
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

    Network {
        _wifi: wifi,
        _mdns: mdns,
    }
}
