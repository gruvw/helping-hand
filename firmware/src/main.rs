use esp_idf_hal::delay::FreeRtos;
use esp_idf_hal::i2c::{I2cConfig, I2cDriver};
use esp_idf_hal::peripherals::Peripherals;
use pwm_pca9685::{Address, Channel, Pca9685};

macro_rules! debug_println {
    ($($arg:tt)*) => {
        #[cfg(debug_assertions)]
        println!($($arg)*)
    };
}

// properties of the servo
const SERVO_FREQUENCY: u32 = 50; // 50 Hz
const SERVO_ANGLE_MIN: f32 = 0.0;
const SERVO_ANGLE_MAX: f32 = 180.0;
const SERVO_ANGLE_MIN_TIME_MS: f32 = 0.5;
const SERVO_ANGLE_MAX_TIME_MS: f32 = 2.5;

// properties of the PCA9685
const PCA9685_FREQUENCY: u32 = 25_000_000; // 25 MHz
const PCA9685_RANGE: u32 = 4096; // 12 bits
const I2C_BAUD_RATE: u32 = 100_000; // 100kHz

// derived constants
const SERVO_PERIOD_MS: f32 = 1000.0 / SERVO_FREQUENCY as f32;
const SERVO_ANGLE_MIN_TICKS: u16 =
    (SERVO_ANGLE_MIN_TIME_MS / SERVO_PERIOD_MS * PCA9685_RANGE as f32).round() as u16;
const SERVO_ANGLE_MAX_TICKS: u16 =
    (SERVO_ANGLE_MAX_TIME_MS / SERVO_PERIOD_MS * PCA9685_RANGE as f32).round() as u16;

// prescale formula (PCA9685 datasheet 7.3.5)
// prescale = round(osc_clock / (4096 × update_rate)) − 1
const PCA9685_PRESCALE: u8 =
    (PCA9685_FREQUENCY as f32 / (PCA9685_RANGE * SERVO_FREQUENCY) as f32 - 1.0).round() as u8;

/// Set angle for the given `channel`, angle is clamped between `SERVO_ANGLE_MIN` and
/// `SERVO_ANGLE_MAX`.
fn move_to_angle<I2C>(pca: &mut Pca9685<I2C>, channel: Channel, angle: f32)
where
    I2C: embedded_hal::i2c::I2c,
{
    let angle = angle.clamp(SERVO_ANGLE_MIN, SERVO_ANGLE_MAX);

    // linear interpolation between min and and max angles ticks
    let ticks = (SERVO_ANGLE_MIN_TICKS as f32
        + (angle - SERVO_ANGLE_MIN)
            * ((SERVO_ANGLE_MAX_TICKS - SERVO_ANGLE_MIN_TICKS) as f32
                / (SERVO_ANGLE_MAX - SERVO_ANGLE_MIN)))
        .round() as u16;

    debug_println!("PCA9685: set channel {:?} to {}°", channel, angle);

    // signal goes high at time 0, goes low at time `ticks`
    pca.set_channel_on_off(channel, 0, ticks)
        .expect("failed to set PCA9685 channel on/off");
}

fn main() -> ! {
    esp_idf_svc::sys::link_patches();

    debug_println!("device started");

    let peripherals = Peripherals::take().expect("failed to take peripherals");
    let sda = peripherals.pins.gpio4;
    let scl = peripherals.pins.gpio5;

    let config = I2cConfig::new().baudrate(I2C_BAUD_RATE.into());
    let i2c = I2cDriver::new(peripherals.i2c0, sda, scl, &config)
        .expect("failed to initialise I2C driver");

    let mut pca = Pca9685::new(i2c, Address::default()).expect("failed to initialise PCA9685");

    pca.set_prescale(PCA9685_PRESCALE)
        .expect("failed to set PCA9685 prescale");
    pca.enable().expect("failed to enable PCA9685");

    debug_println!("device intitialized");

    loop {
        move_to_angle(&mut pca, Channel::C0, SERVO_ANGLE_MAX);
        FreeRtos::delay_ms(1000);

        move_to_angle(&mut pca, Channel::C0, SERVO_ANGLE_MIN);
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
