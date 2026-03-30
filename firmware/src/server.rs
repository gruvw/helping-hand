use std::sync::Arc;
use std::sync::Mutex;

use esp_idf_svc::http::server::Configuration as HttpConfiguration;
use esp_idf_svc::http::server::EspHttpServer;
use esp_idf_svc::http::Method;

use crate::logic::handle_click;
use crate::logic::handle_index;
use crate::logic::handle_reset;
use crate::logic::handle_set;
use crate::servo::ServoManager;

const LOG_TAG: &str = "server";

pub fn server_setup(sm: Arc<Mutex<ServoManager<'static>>>) -> EspHttpServer<'static> {
    let mut server =
        EspHttpServer::new(&HttpConfiguration::default()).expect("failed to create HTTP server");

    server
        .fn_handler("/", Method::Get, handle_index)
        .expect("failed to set home HTTP handler");

    let click_sm = sm.clone();
    server
        .fn_handler("/click", Method::Get, move |req| {
            handle_click(req, &click_sm)
        })
        .expect("failed to set click HTTP handler");

    let set_sm = sm.clone();
    server
        .fn_handler("/set", Method::Get, move |req| handle_set(req, &set_sm))
        .expect("failed to set set HTTP handler");

    let reset_sm = sm.clone();
    server
        .fn_handler("/reset", Method::Get, move |req| {
            handle_reset(req, &reset_sm)
        })
        .expect("failed to set reset HTTP handler");

    log::info!(target: LOG_TAG, "web server running");

    server
}
