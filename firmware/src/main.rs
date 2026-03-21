use std::sync::Arc;
use std::sync::Mutex;

use esp_idf_hal::delay::FreeRtos;
use esp_idf_hal::peripherals::Peripherals;

use helping_hand::network::network_setup;
use helping_hand::server::server_setup;
use helping_hand::servo::ServoManager;

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

    let _network = network_setup(peripherals.modem);
    let _server = server_setup(sm);

    log::info!(target: LOG_TAG, "device intitialized");

    loop {
        FreeRtos::delay_ms(u32::MAX);
    }
}
