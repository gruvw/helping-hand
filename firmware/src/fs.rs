use std::fs;

use esp_idf_svc::fs::spiffs::Spiffs;

const PARTITION_LABEL: &str = "spiffs";
const CONFIG_PATH: &str = "/spiffs/config.txt";

const LOG_TAG: &str = "fs";

pub fn fs_setup() -> Spiffs {
    let spiffs = unsafe { Spiffs::new(PARTITION_LABEL) };
    let mut spiffs = spiffs.expect("failed to mount SPIFFS filesystem");
    spiffs.format().expect("aa");

    log::info!(target: LOG_TAG, "SPIFFS mounted at /{}", PARTITION_LABEL);

    spiffs
}

pub fn get_config() -> String {
    fs::read_to_string(CONFIG_PATH).unwrap_or(String::new())
}

pub fn store_config(config: String) {
    match fs::write(CONFIG_PATH, config) {
        Ok(_) => {
            log::info!(target: LOG_TAG, "config successfully saved to {}", CONFIG_PATH);
        }
        Err(e) => {
            log::error!(target: LOG_TAG, "failed to write config: {}", e);
        }
    }
}
