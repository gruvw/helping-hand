use anyhow::Result;
use embedded_svc::http::Method;
use esp_idf_svc::eventloop::EspSystemEventLoop;
use esp_idf_svc::hal::prelude::Peripherals;
use esp_idf_svc::http::server::EspHttpServer;
use esp_idf_svc::nvs::EspDefaultNvsPartition;
use esp_idf_svc::wifi::{AccessPointConfiguration, Configuration, EspWifi};
use std::thread::sleep;
use std::time::Duration;

fn main() -> Result<()> {
    esp_idf_sys::link_patches();

    let peripherals = Peripherals::take().unwrap();
    let sys_loop = EspSystemEventLoop::take()?;
    let nvs = EspDefaultNvsPartition::take()?;

    // 1. Initialize Wi-Fi
    let mut wifi = EspWifi::new(peripherals.modem, sys_loop, Some(nvs))?;

    wifi.set_configuration(&Configuration::AccessPoint(AccessPointConfiguration {
        ssid: "Rust-ESP32-C6".into(),
        ssid_hidden: false,
        auth_method: embedded_svc::wifi::AuthMethod::None, // Open network for simplicity
        ..Default::default()
    }))?;

    wifi.start()?;
    println!("Wi-Fi AP started!");

    // 2. Set up Web Server
    let mut server = EspHttpServer::new(&esp_idf_svc::http::server::Configuration::default())?;

    server.fn_handler("/", Method::Get, |req| {
        req.into_ok_response()?
            .write_all("<html><body><h1>Hello World from ESP32-C6!</h1></body></html>".as_bytes())?;
        Ok(())
    })?;

    println!("Server is running on 192.168.4.1");

    // 3. Keep the program alive
    loop {
        sleep(Duration::from_secs(1));
    }
}
