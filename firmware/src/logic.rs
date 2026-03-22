use std::{
    sync::{Arc, Mutex},
    time::Duration,
};

use esp_idf_svc::http::server::{EspHttpConnection, Request};
use pwm_pca9685::Channel;

use crate::servo::ServoManager;

const LOG_TAG: &str = "logic";

pub fn handle_index(req: Request<&mut EspHttpConnection>) -> anyhow::Result<()> {
    log::info!(target: LOG_TAG, "index handling");

    let mut response = req.into_ok_response()?;
    response.write(b"Hello World!")?;
    Ok(())
}

pub fn handle_click(
    req: Request<&mut EspHttpConnection>,
    sm: &Arc<Mutex<ServoManager>>,
) -> anyhow::Result<()> {
    log::info!(target: LOG_TAG, "click handling");

    let uri = req.uri();
    let query = uri.split_once('?').map(|(_, q)| q).unwrap_or("");

    let mut channel_nb: u8 = 0;
    let mut angle: f32 = 0.0;
    let mut duration_ms: u64 = 0;

    for pair in query.split('&') {
        if let Some((key, value)) = pair.split_once('=') {
            match key {
                "channel" => channel_nb = value.parse().unwrap_or(channel_nb),
                "angle" => angle = value.parse().unwrap_or(angle),
                "duration" => duration_ms = value.parse().unwrap_or(duration_ms),
                _ => {
                    let mut response = req.into_response(400, Some("Bad Request"), &[])?;
                    response.write(b"invalid query parameter")?;
                    return Ok(());
                }
            }
        }
    }

    log::info!(
        target: LOG_TAG,
        "click parameters: channel={}, angle={}, duration={}ms",
        channel_nb,
        angle,
        duration_ms,
    );

    let channel = match channel_nb {
        0 => Channel::C0,
        1 => Channel::C1,
        2 => Channel::C2,
        3 => Channel::C3,
        4 => Channel::C4,
        5 => Channel::C5,
        _ => {
            let mut response = req.into_response(400, Some("Bad Request"), &[])?;
            response.write(b"invalid channel")?;
            return Ok(());
        }
    };

    sm.lock()
        .expect("failed to acquire servo manager mutex")
        .click(channel, angle, Duration::from_millis(duration_ms));

    Ok(())
}
