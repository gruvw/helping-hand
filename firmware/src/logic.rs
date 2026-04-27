use std::{
    sync::{Arc, Mutex},
    time::Duration,
};

use esp_idf_svc::http::server::{EspHttpConnection, Request};
use pwm_pca9685::Channel;

use crate::{
    fs::{get_config, store_config},
    server::{HttpStatus, RequestExt},
    servo::ServoManager,
};

const LOG_TAG: &str = "logic";

fn map_channel(nb: u8) -> Option<Channel> {
    match nb {
        0 => Some(Channel::C7),
        1 => Some(Channel::C8),
        2 => Some(Channel::C9),
        3 => Some(Channel::C10),
        4 => Some(Channel::C11),
        5 => Some(Channel::C12),
        6 => Some(Channel::C13),
        7 => Some(Channel::C14),
        20 => Some(Channel::All),
        _ => None,
    }
}

pub fn handle_index(req: Request<&mut EspHttpConnection>) -> anyhow::Result<()> {
    log::info!(target: LOG_TAG, "index handling");

    let headers = [("Content-Type", "text/plain")];

    let mut response = req.into_cors_response(HttpStatus::Ok, &headers)?;
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
                    return req.bad_request("invalid query parameter");
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
        None => return req.bad_request("invalid channel"),
    };

    sm.lock()
        .expect("failed to acquire servo manager mutex")
        .click(channel, angle, Duration::from_millis(duration_ms));

    req.into_cors_response(HttpStatus::NoContent, &[])?;

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
                    return req.bad_request("invalid query parameter");
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
        None => return req.bad_request("invalid channel"),
    };

    sm.lock()
        .expect("failed to acquire servo manager mutex")
        .set(channel, angle);

    req.into_cors_response(HttpStatus::NoContent, &[])?;

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
                    return req.bad_request("invalid query parameter");
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
        None => return req.bad_request("invalid channel"),
    };

    sm.lock()
        .expect("failed to acquire servo manager mutex")
        .reset(channel);

    req.into_cors_response(HttpStatus::NoContent, &[])?;

    Ok(())
}

pub fn handle_get_config(req: Request<&mut EspHttpConnection>) -> anyhow::Result<()> {
    log::info!(target: LOG_TAG, "get-config handling");

    let config = get_config();

    let mut response = req.into_cors_response(HttpStatus::Ok, &[("Content-Type", "text/plain")])?;
    response.write(config.as_bytes())?;

    Ok(())
}

pub fn handle_store_config(
    req: Request<&mut EspHttpConnection>,
    body: String,
) -> anyhow::Result<()> {
    log::info!(target: LOG_TAG, "store-config handling");

    store_config(body);

    req.into_cors_response(HttpStatus::NoContent, &[])?;

    Ok(())
}
