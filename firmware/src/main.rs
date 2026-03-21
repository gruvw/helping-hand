use esp_idf_hal::delay::FreeRtos;
use esp_idf_hal::peripherals::Peripherals;
use pwm_pca9685::Channel;

use helping_hand::debug_println;
use helping_hand::servo::ServoManager;

fn main() -> ! {
    esp_idf_svc::sys::link_patches();

    debug_println!("device started");

    let peripherals = Peripherals::take().expect("failed to take peripherals");
    let mut servos = ServoManager::new(
        peripherals.i2c0,
        peripherals.pins.gpio4, // SDA
        peripherals.pins.gpio5, // SCL
    );

    debug_println!("device intitialized");

    loop {
        servos.move_to_angle(Channel::C0, SERVO_ANGLE_MAX);
        FreeRtos::delay_ms(1000);

        servos.move_to_angle(Channel::C0, SERVO_ANGLE_MIN);
        FreeRtos::delay_ms(1000);
    }
}

// use esp_idf_svc::eventloop::EspSystemEventLoop;
// use esp_idf_svc::hal::peripherals::Peripherals;
// use esp_idf_svc::http::server::Configuration;
// use esp_idf_svc::http::server::EspHttpServer;
// use esp_idf_svc::http::Method;
// use esp_idf_svc::ipv4::{
//     Configuration as IpConfiguration, Ipv4Addr, Mask, RouterConfiguration, Subnet,
// };
// use esp_idf_svc::netif::{EspNetif, NetifConfiguration, NetifStack};
// use esp_idf_svc::nvs::EspDefaultNvsPartition;
// use esp_idf_svc::wifi::{
//     AccessPointConfiguration, AuthMethod, Configuration as WifiConfiguration, EspWifi, WifiDriver,
// };
// use std::{thread, time::Duration};

// fn main() -> anyhow::Result<()> {
//     esp_idf_svc::sys::link_patches();
//     esp_idf_svc::log::EspLogger::initialize_default();

//     let peripherals = Peripherals::take()?;
//     let sys_loop = EspSystemEventLoop::take()?;
//     let nvs = EspDefaultNvsPartition::take()?;

//     // ── 1. Build a custom AP netif locked to 192.168.4.1/24 ──────────────
//     let ap_netif = EspNetif::new_with_conf(&NetifConfiguration {
//         ip_configuration: Some(IpConfiguration::Router(RouterConfiguration {
//             subnet: Subnet {
//                 gateway: Ipv4Addr::from(std::net::Ipv4Addr::new(192, 168, 4, 1)),
//                 mask: Mask(24),
//             },
//             dhcp_enabled: true,
//             dns: None,
//             secondary_dns: None,
//         })),
//         // Inherit the rest of the default AP netif config (key, flags, …)
//         ..NetifConfiguration::wifi_default_router()
//     })?;

//     // ── 2. Low-level driver + default STA netif, then attach the custom AP netif ──
//     let driver = WifiDriver::new(peripherals.modem, sys_loop.clone(), Some(nvs))?;
//     let sta_netif = EspNetif::new(NetifStack::Sta)?;
//     let mut wifi = EspWifi::wrap_all(driver, sta_netif, ap_netif)?;

//     // ── 3. Normal AP configuration ────────────────────────────────────────
//     wifi.set_configuration(&WifiConfiguration::AccessPoint(AccessPointConfiguration {
//         ssid: "ESP32-Rust-Server".try_into().unwrap(),
//         password: "rust-is-cool".try_into().unwrap(),
//         auth_method: AuthMethod::WPA2WPA3Personal,
//         ..Default::default()
//     }))?;

//     wifi.start()?;
//     log::info!("Wi-Fi AP started! Gateway: 192.168.4.1");

//     // ── 4. HTTP server ────────────────────────────────────────────────────
//     let mut server = EspHttpServer::new(&Configuration::default())?;

//     server.fn_handler("/", Method::Get, |req| -> anyhow::Result<()> {
//         let mut response = req.into_ok_response()?;
//         response.write(b"<h1>Hello from Rust on ESP32!</h1>")?;
//         Ok(())
//     })?;

//     log::info!("Web server running on http://192.168.4.1/");

//     loop {
//         thread::sleep(Duration::from_secs(1));
//     }
// }
