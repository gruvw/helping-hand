use const_format::formatcp;
use esp_idf_hal::sys::{
    CONFIG_WL_SECTOR_SIZE, ESP_OK, WL_INVALID_HANDLE, esp_vfs_fat_mount_config_t,
    esp_vfs_fat_spiflash_mount_rw_wl, wl_handle_t,
};
use std::ffi::CString;
use std::fs;

const PARTITION_LABEL: &str = "storage";
const BASE_PATH: &str = "/fatfs";
const CONFIG_PATH: &str = formatcp!("{}/config.txt", BASE_PATH);

const LOG_TAG: &str = "fs";

pub fn fs_setup() {
    log::info!(target: LOG_TAG, "setting up the file system");

    let partition_label = CString::new(PARTITION_LABEL).unwrap();
    let base_path = CString::new(BASE_PATH).unwrap();

    let mount_config = esp_vfs_fat_mount_config_t {
        format_if_mount_failed: true,
        max_files: 5,
        allocation_unit_size: CONFIG_WL_SECTOR_SIZE as usize,
        ..Default::default()
    };

    let mut wl_handle: wl_handle_t = WL_INVALID_HANDLE;

    let ret = unsafe {
        esp_vfs_fat_spiflash_mount_rw_wl(
            base_path.as_ptr(),
            partition_label.as_ptr(),
            &mount_config,
            &mut wl_handle,
        )
    };

    if ret != ESP_OK {
        log::error!(target: LOG_TAG, "failed to mount FATFS (0x{:x})", ret);
    } else {
        log::info!(target: LOG_TAG, "FATFS mounted successfully at {}", BASE_PATH);
    }
}

pub fn get_config() -> String {
    fs::read_to_string(CONFIG_PATH).unwrap_or_default()
}

pub fn store_config(config: String) {
    match fs::write(CONFIG_PATH, config) {
        Ok(_) => log::info!(target: LOG_TAG, "Config saved to {}", CONFIG_PATH),
        Err(e) => log::error!(target: LOG_TAG, "Failed to write config: {}", e),
    }
}
