use std::sync::Arc;
use std::sync::Mutex;

use esp_idf_svc::http::server::Configuration as HttpConfiguration;
use esp_idf_svc::http::server::EspHttpServer;
use esp_idf_svc::http::Method;

use crate::logic::handle_click;
use crate::logic::handle_index;
use crate::servo::ServoManager;

const LOG_TAG: &str = "server";

pub fn server_setup(sm: Arc<Mutex<ServoManager<'static>>>) -> EspHttpServer<'static> {
    let mut server =
        EspHttpServer::new(&HttpConfiguration::default()).expect("failed to create HTTP server");

    server
        .fn_handler("/", Method::Get, handle_index)
        .expect("failed to set home HTTP handler");
    server
        .fn_handler("/click", Method::Get, move |req| handle_click(req, &sm))
        .expect("failed to set click HTTP handler");

    log::info!(target: LOG_TAG, "web server running");

    server
}
