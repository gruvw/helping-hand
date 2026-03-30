use esp_idf_hal::modem::Modem;
use esp_idf_svc::eventloop::EspSystemEventLoop;
use esp_idf_svc::ipv4::{
    Configuration as IpConfiguration, Ipv4Addr, Mask, RouterConfiguration, Subnet,
};
use esp_idf_svc::mdns::EspMdns;
use esp_idf_svc::netif::{EspNetif, NetifConfiguration, NetifStack};
use esp_idf_svc::nvs::EspDefaultNvsPartition;
use esp_idf_svc::wifi::{
    AccessPointConfiguration, AuthMethod, ClientConfiguration, Configuration as WifiConfiguration,
    EspWifi, WifiDriver,
};

const DEVICE_ID: &str = env!("DEVICE_ID");
const NET_SSID: &str = env!("NET_SSID");
const NET_PWD: &str = env!("NET_PWD");
const NET_AP_PWD: &str = env!("NET_AP_PWD");

const LOG_TAG: &str = "network";

pub struct Network {
    _wifi: EspWifi<'static>,
    _mdns: EspMdns,
}

pub fn network_setup(modem: Modem<'static>) -> Network {
    let sys_loop = EspSystemEventLoop::take().expect("failed to take event loop");
    let nvs = EspDefaultNvsPartition::take().expect("failed to take NVS partition");
    let driver =
        WifiDriver::new(modem, sys_loop.clone(), Some(nvs)).expect("failed to create Wi-Fi driver");

    let name = format!("HH-{}", DEVICE_ID);

    let sta_netif = EspNetif::new(NetifStack::Sta).expect("failed to create station netif");

    let ap_netif = if NET_SSID.is_empty() {
        let gateway = std::net::Ipv4Addr::new(192, 168, 1, 1);
        EspNetif::new_with_conf(&NetifConfiguration {
            ip_configuration: Some(IpConfiguration::Router(RouterConfiguration {
                subnet: Subnet {
                    gateway: Ipv4Addr::from(gateway),
                    mask: Mask(24),
                },
                dhcp_enabled: true,
                dns: None,
                secondary_dns: None,
            })),
            ..NetifConfiguration::wifi_default_router()
        })
        .expect("failed to create AP netif")
    } else {
        EspNetif::new(NetifStack::Ap).expect("failed to create default AP netif")
    };

    let mut wifi = EspWifi::wrap_all(driver, sta_netif, ap_netif).expect("failed to wrap Wi-Fi");

    if !NET_SSID.is_empty() {
        log::info!(target: LOG_TAG, "Connecting to Wi-Fi: {}", NET_SSID);
        wifi.set_configuration(&WifiConfiguration::Client(ClientConfiguration {
            ssid: NET_SSID.try_into().unwrap(),
            password: NET_PWD.try_into().unwrap(),
            auth_method: AuthMethod::WPA2WPA3Personal,
            ..Default::default()
        }))
        .expect("failed to set STA config");

        wifi.start().expect("failed to start Wi-Fi");
        wifi.connect().expect("failed to connect to Wi-Fi");
    } else {
        log::info!(target: LOG_TAG, "Starting Wi-Fi AP: {}", name);
        wifi.set_configuration(&WifiConfiguration::AccessPoint(AccessPointConfiguration {
            ssid: name.as_str().try_into().unwrap(),
            password: NET_AP_PWD.try_into().unwrap(),
            auth_method: AuthMethod::WPA2WPA3Personal,
            ..Default::default()
        }))
        .expect("failed to set AP config");

        wifi.start().expect("failed to start Wi-Fi AP");
    }

    let mut mdns = EspMdns::take().expect("failed to take mDNS");
    mdns.set_hostname(&name)
        .expect("failed to set mDNS hostname");
    log::info!(target: LOG_TAG, "mDNS configured: {}.local", name);

    Network {
        _wifi: wifi,
        _mdns: mdns,
    }
}
