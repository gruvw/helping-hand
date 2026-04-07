use std::env;

const NET_SSID: &str = "ssid"; // AP mode if empty
const NET_PWD: &str = "pwd";

const NET_AP_PWD: &str = "Helping-HAND";
const DEVICE_ID: &str = "0001";

fn main() {
    embuild::espidf::sysenv::output();

    // load .env file
    let _ = dotenvy::dotenv();
    println!("cargo:rerun-if-changed=.env");

    let net_ssid = env::var("NET_SSID").unwrap_or(NET_SSID.to_string());
    let net_pwd = env::var("NET_PWD").unwrap_or(NET_PWD.to_string());

    println!("cargo:rustc-env=NET_SSID={}", net_ssid);
    println!("cargo:rustc-env=NET_PWD={}", net_pwd);

    println!("cargo:rustc-env=NET_AP_PWD={}", NET_AP_PWD);
    println!("cargo:rustc-env=DEVICE_ID={}", DEVICE_ID);
}
