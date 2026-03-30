const NET_SSID: &str = ""; // AP mode if empty
const NET_PWD: &str = "XXXX";

const NET_AP_PWD: &str = "Helping-HAND";

const DEVICE_ID: &str = "0001";

fn main() {
    embuild::espidf::sysenv::output();

    println!("cargo:rustc-env=NET_SSID={}", NET_SSID);
    println!("cargo:rustc-env=NET_PWD={}", NET_PWD);

    println!("cargo:rustc-env=NET_AP_PWD={}", NET_AP_PWD);

    println!("cargo:rustc-env=DEVICE_ID={}", DEVICE_ID);
}
