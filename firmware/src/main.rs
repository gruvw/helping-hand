use std::{thread, time::Duration};

fn main() {
    // It is necessary to call this function once. Otherwise, some patches to the runtime
    // implemented by esp-idf-sys might not link properly. See https://github.com/esp-rs/esp-idf-template/issues/71
    esp_idf_svc::sys::link_patches();

    // Bind the log crate to the ESP Logging facilities
    esp_idf_svc::log::EspLogger::initialize_default();

    log::info!("Hello, world!");

    let mut count = 0;

    loop {
        count += 1;
        log::info!("Loop iteration: {}", count);

        // Sleep for 1 second so we don't flood the console
        thread::sleep(Duration::from_secs(1));
    }
}
