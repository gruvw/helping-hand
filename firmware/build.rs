use std::{env, fs, path::PathBuf};

use rcgen::{BasicConstraints, CertificateParams, DistinguishedName, DnType, IsCa, KeyPair};

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

    let device_name = format!("hh-{}", DEVICE_ID);

    println!("cargo:rustc-env=NET_AP_PWD={}", NET_AP_PWD);
    println!("cargo:rustc-env=DEVICE_ID={}", DEVICE_ID);
    println!("cargo:rustc-env=DEVICE_NAME={}", device_name);

    let cert_dir = PathBuf::from("certs");
    fs::create_dir_all(&cert_dir).unwrap();

    let cert_path = cert_dir.join(format!("server-{}.crt", DEVICE_ID));
    let key_path = cert_dir.join(format!("server-{}.key", DEVICE_ID));

    if !cert_path.exists() || !key_path.exists() {
        let domain = format!("{}.local", device_name);

        let mut params =
            CertificateParams::new([domain.clone()]).expect("could not create certificate params");
        params.is_ca = IsCa::Ca(BasicConstraints::Constrained(0));

        let mut dn = DistinguishedName::new();
        dn.push(DnType::CommonName, domain);
        params.distinguished_name = dn;

        let key_pair = KeyPair::generate().expect("failed to generate key pair");
        let cert = params.self_signed(&key_pair).expect("failed to sign cert");

        let mut cert_pem = cert.pem().into_bytes();
        let mut key_pem = key_pair.serialize_pem().into_bytes();

        cert_pem.push(0);
        key_pem.push(0);

        // TODO cert will expire after 1 year, will need refresh & reflash

        fs::write(&cert_path, cert_pem).expect("failed to write the certificate");
        fs::write(&key_path, key_pem).expect("failed to write the key");
    }

    println!("cargo:rerun-if-changed=certs/");
}
