use anyhow::Result;
use esp_idf_hal::delay::FreeRtos;
use esp_idf_hal::i2c::{I2cConfig, I2cDriver};
use esp_idf_hal::peripherals::Peripherals;
use esp_idf_hal::units::FromValueType;
use pwm_pca9685::{Address, Channel, Pca9685};

fn main() -> Result<()> {
    // Standard ESP-IDF patch linking
    esp_idf_svc::sys::link_patches();

    println!("Starting PCA9685 Servo Sweep...");

    // 1. Take peripherals
    let peripherals = Peripherals::take().unwrap();

    // 2. Configure I2C on Pins 4 (SDA) and 5 (SCL)
    let sda = peripherals.pins.gpio4;
    let scl = peripherals.pins.gpio5;

    // 100 kHz is the standard I2C speed, which is plenty for the PCA9685
    let config = I2cConfig::new().baudrate(100.kHz().into());
    let i2c = I2cDriver::new(peripherals.i2c0, sda, scl, &config)?;

    // 3. Initialize the PCA9685
    // Address::default() uses the default 0x40 I2C address for the PCA9685
    let mut pwm = Pca9685::new(i2c, Address::default()).unwrap();

    // 4. Configure PWM frequency to 50Hz for the servo
    // The PCA9685 internal clock is 25MHz.
    // Prescale formula: (25,000,000 / (4096 * 50Hz)) - 1 = ~121
    pwm.set_prescale(121).unwrap();
    pwm.enable().unwrap();

    // 5. Define our sweep ticks based on your requirements
    // 1ms = 205 ticks
    // 4ms = 819 ticks
    let min_tick = 205;
    let max_tick = 819;

    println!(
        "Sweeping from 1ms ({} ticks) to 4ms ({} ticks)...",
        min_tick, max_tick
    );

    // 6. Sweep Loop
    loop {
        // Sweep up (0 to 180 degrees)
        for tick in min_tick..=max_tick {
            // Channel::C0 corresponds to the "0" pin on the PCA9685 board
            // We turn the pulse ON at tick 0, and OFF at our calculated tick
            pwm.set_channel_on_off(Channel::C0, 0, tick).unwrap();

            // Adjust this delay to make the sweep faster or slower
            FreeRtos::delay_ms(5);
        }

        FreeRtos::delay_ms(500); // Pause at 180 degrees

        // Sweep down (180 to 0 degrees)
        for tick in (min_tick..=max_tick).rev() {
            pwm.set_channel_on_off(Channel::C0, 0, tick).unwrap();
            FreeRtos::delay_ms(5);
        }

        FreeRtos::delay_ms(500); // Pause at 0 degrees
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
