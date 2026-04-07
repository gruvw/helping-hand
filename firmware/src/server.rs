use std::sync::Arc;
use std::sync::Mutex;

use esp_idf_svc::http::server::Configuration as HttpConfiguration;
use esp_idf_svc::http::server::EspHttpConnection;
use esp_idf_svc::http::server::EspHttpServer;
use esp_idf_svc::http::server::Request;
use esp_idf_svc::http::Method;

use crate::logic::handle_click;
use crate::logic::handle_get_config;
use crate::logic::handle_index;
use crate::logic::handle_reset;
use crate::logic::handle_set;
use crate::logic::handle_store_config;
use crate::servo::ServoManager;

const BODY_MAX_SIZE: usize = 4096;
const BODY_BUFFER_SIZE: usize = 512;

const LOG_TAG: &str = "server";

fn read_body(req: &mut Request<&mut EspHttpConnection>, max_len: usize) -> anyhow::Result<String> {
    let mut body_bytes = Vec::new();
    let mut buf = [0u8; BODY_BUFFER_SIZE];

    loop {
        let len = req.read(&mut buf)?;
        if len == 0 {
            break;
        }
        if body_bytes.len() + len > max_len {
            anyhow::bail!("request body too large");
        }
        body_bytes.extend_from_slice(&buf[..len]);
    }

    let body = String::from_utf8(body_bytes)?;

    Ok(body)
}

pub fn server_setup(sm: Arc<Mutex<ServoManager<'static>>>) -> EspHttpServer<'static> {
    let mut server =
        EspHttpServer::new(&HttpConfiguration::default()).expect("failed to create HTTP server");

    server
        .fn_handler("/", Method::Get, handle_index)
        .expect("failed to set home HTTP handler");

    server
        .fn_handler("/config", Method::Get, move |req| handle_get_config(req))
        .expect("failed to set get-config HTTP handler");
    server
        .fn_handler("/config", Method::Post, move |mut req| {
            let body = read_body(&mut req, BODY_MAX_SIZE)?;
            handle_store_config(req, body)
        })
        .expect("failed to set store-config HTTP handler");

    let click_sm = sm.clone();
    server
        .fn_handler("/click", Method::Post, move |req| {
            handle_click(req, &click_sm)
        })
        .expect("failed to set click HTTP handler");

    let set_sm = sm.clone();
    server
        .fn_handler("/set", Method::Post, move |req| handle_set(req, &set_sm))
        .expect("failed to set set HTTP handler");

    let reset_sm = sm.clone();
    server
        .fn_handler("/reset", Method::Post, move |req| {
            handle_reset(req, &reset_sm)
        })
        .expect("failed to set reset HTTP handler");

    log::info!(target: LOG_TAG, "web server running");

    server
}
