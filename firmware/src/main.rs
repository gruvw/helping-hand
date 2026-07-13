use std::sync::Arc;
use std::sync::Mutex;

use esp_idf_hal::delay::FreeRtos;

use esp_idf_svc::log::EspLogger;
use helping_hand::fs::fs_setup;
use helping_hand::network::network_setup;
use helping_hand::server::server_setup;
use helping_hand::servo::ServoManager;

use esp_idf_hal::peripherals::Peripherals;

use helping_hand::ir::IrManager;

const LOG_TAG: &str = "main";

fn main() -> ! {
    esp_idf_svc::sys::link_patches();
    EspLogger::initialize_default();

    log::info!(target: LOG_TAG, "device started");

    let peripherals = Peripherals::take().expect("failed to take peripherals");

    let _fs = fs_setup();
    let _network = network_setup(peripherals.modem);

    let _server = if env!("DEVICE_ID").starts_with("1") {
        let ir = IrManager::new(peripherals.pins.gpio2, peripherals.pins.gpio3);
        let ir = Arc::new(Mutex::new(ir));

        server_setup(None, Some(ir))
    } else {
        let sm = ServoManager::new(
            peripherals.i2c0,
            peripherals.pins.gpio4, // SDA
            peripherals.pins.gpio5, // SCL
        );
        let sm = Arc::new(Mutex::new(sm));

        server_setup(Some(sm), None)
    };

    log::info!(target: LOG_TAG, "device intitialized");

    // keep alive loop
    loop {
        FreeRtos::delay_ms(u32::MAX);
    }
}
