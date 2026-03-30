use std::{
    sync::{Arc, Mutex},
    time::Duration,
};

use esp_idf_svc::http::server::{EspHttpConnection, Request};
use pwm_pca9685::Channel;

use crate::servo::ServoManager;

const LOG_TAG: &str = "logic";

fn bad_request(req: Request<&mut EspHttpConnection>, msg: &str) -> anyhow::Result<()> {
    let mut response = req.into_response(400, Some("Bad Request"), &[])?;
    response.write(msg.as_bytes())?;
    Ok(())
}

fn map_channel(nb: u8) -> Option<Channel> {
    match nb {
        0 => Some(Channel::C0),
        1 => Some(Channel::C1),
        2 => Some(Channel::C2),
        3 => Some(Channel::C3),
        4 => Some(Channel::C4),
        5 => Some(Channel::C5),
        6 => Some(Channel::C6),
        7 => Some(Channel::C7),
        _ => None,
    }
}

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
                    return bad_request(req, "invalid query parameter");
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

    let channel = match map_channel(channel_nb) {
        Some(c) => c,
        None => return bad_request(req, "invalid channel"),
    };

    sm.lock()
        .expect("failed to acquire servo manager mutex")
        .click(channel, angle, Duration::from_millis(duration_ms));

    Ok(())
}

pub fn handle_set(
    req: Request<&mut EspHttpConnection>,
    sm: &Arc<Mutex<ServoManager>>,
) -> anyhow::Result<()> {
    log::info!(target: LOG_TAG, "set handling");

    let uri = req.uri();
    let query = uri.split_once('?').map(|(_, q)| q).unwrap_or("");

    let mut channel_nb: u8 = 0;
    let mut angle: f32 = 0.0;

    for pair in query.split('&') {
        if let Some((key, value)) = pair.split_once('=') {
            match key {
                "channel" => channel_nb = value.parse().unwrap_or(channel_nb),
                "angle" => angle = value.parse().unwrap_or(angle),
                _ => {
                    return bad_request(req, "invalid query parameter");
                }
            }
        }
    }

    log::info!(
        target: LOG_TAG,
        "set parameters: channel={}, angle={}",
        channel_nb,
        angle,
    );

    let channel = match map_channel(channel_nb) {
        Some(c) => c,
        None => return bad_request(req, "invalid channel"),
    };

    sm.lock()
        .expect("failed to acquire servo manager mutex")
        .set(channel, angle);

    Ok(())
}

pub fn handle_reset(
    req: Request<&mut EspHttpConnection>,
    sm: &Arc<Mutex<ServoManager>>,
) -> anyhow::Result<()> {
    log::info!(target: LOG_TAG, "reset handling");

    let uri = req.uri();
    let query = uri.split_once('?').map(|(_, q)| q).unwrap_or("");

    let mut channel_nb: u8 = 0;

    for pair in query.split('&') {
        if let Some((key, value)) = pair.split_once('=') {
            match key {
                "channel" => channel_nb = value.parse().unwrap_or(channel_nb),
                _ => {
                    return bad_request(req, "invalid query parameter");
                }
            }
        }
    }

    log::info!(
        target: LOG_TAG,
        "release parameters: channel={}",
        channel_nb,
    );

    let channel = match map_channel(channel_nb) {
        Some(c) => c,
        None => return bad_request(req, "invalid channel"),
    };

    sm.lock()
        .expect("failed to acquire servo manager mutex")
        .reset(channel);

    Ok(())
}
