const DEVICE_ID: &str = "0001";

fn main() {
    embuild::espidf::sysenv::output();

    println!("cargo:rustc-env=DEVICE_ID={}", DEVICE_ID);
}
