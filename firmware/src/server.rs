use std::sync::Arc;
use std::sync::Mutex;

use const_format::formatcp;
use esp_idf_hal::io::EspIOError;
use esp_idf_hal::sys::EspError;
use esp_idf_svc::http::Method;
use esp_idf_svc::http::server::Configuration as HttpConfiguration;
use esp_idf_svc::http::server::Connection;
use esp_idf_svc::http::server::EspHttpConnection;
use esp_idf_svc::http::server::EspHttpServer;
use esp_idf_svc::http::server::Request;
use esp_idf_svc::http::server::Response;
use esp_idf_svc::tls::X509;

use crate::logic::handle_click;
use crate::logic::handle_get_config;
use crate::logic::handle_index;
use crate::logic::handle_reset;
use crate::logic::handle_set;
use crate::logic::handle_store_config;
use crate::servo::ServoManager;

// TODO improve detection (only http and https protocols)
const ALLOWED_ORIGIN_SUFFIX: &str = "://hh.gruvw.com";
const ALLOWED_ORIGIN: &str = formatcp!("https{}", ALLOWED_ORIGIN_SUFFIX);

const BODY_MAX_SIZE: usize = 4096;
const BODY_BUFFER_SIZE: usize = 512;

macro_rules! include_certs {
    ($path:literal, $prefix:literal, $env_var:literal) => {
        const SERVER_CERT_NAME: &str = concat!($prefix, env!($env_var), ".crt");
        static SERVER_CERT: &[u8] = include_bytes!(concat!($path, $prefix, env!($env_var), ".crt"));
        static SERVER_KEY: &[u8] = include_bytes!(concat!($path, $prefix, env!($env_var), ".key"));
    };
}

include_certs!("../certs/", "server-", "DEVICE_ID");

const LOG_TAG: &str = "server";

#[repr(u16)]
pub enum HttpStatus {
    Ok = 200,
    NoContent = 204,
    BadRequest = 400,
    NotFound = 404,
    InternalError = 500,
}

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

fn allowed_origin(req: &Request<&mut EspHttpConnection>) -> String {
    #[cfg(debug_assertions)]
    {
        if let Some(origin) = req.header("Origin")
            && origin.starts_with("http://localhost:")
        {
            return origin.to_string();
        }
    }

    if let Some(origin) = req.header("Origin")
        && origin.ends_with(ALLOWED_ORIGIN_SUFFIX)
    {
        return origin.to_string();
    }

    ALLOWED_ORIGIN.to_string()
}

fn handle_pna_preflight(req: Request<&mut EspHttpConnection>) -> anyhow::Result<()> {
    let allowed_origin = allowed_origin(&req);

    log::info!(target: LOG_TAG, "PNA preflight OPTION request handling: allowed origin {}",
        allowed_origin);

    let headers = [
        ("Access-Control-Allow-Origin", allowed_origin.as_str()),
        ("Access-Control-Allow-Private-Network", "true"),
        ("Access-Control-Allow-Methods", "GET, OPTIONS, POST"),
        ("Access-Control-Allow-Headers", "Content-Type"),
        ("Access-Control-Max-Age", "86400"),
    ];

    req.into_response(HttpStatus::NoContent as u16, None, &headers)?;

    Ok(())
}

pub trait RequestExt<'a, 'b, C>
where
    C: Connection,
{
    fn into_cors_response(
        self,
        status: HttpStatus,
        additional_headers: &[(&str, &str)],
    ) -> anyhow::Result<Response<&'a mut C>, C::Error>;

    fn bad_request(self, msg: &str) -> anyhow::Result<()>;
}

impl<'a, 'b> RequestExt<'a, 'b, EspHttpConnection<'b>> for Request<&'a mut EspHttpConnection<'b>> {
    fn into_cors_response(
        self,
        status: HttpStatus,
        additional_headers: &[(&str, &str)],
    ) -> anyhow::Result<Response<&'a mut EspHttpConnection<'b>>, EspIOError> {
        let allowed_origin = allowed_origin(&self);
        let headers = [("Access-Control-Allow-Origin", allowed_origin.as_str())];

        let headers: Vec<(&str, &str)> = headers
            .iter()
            .copied()
            .chain(additional_headers.iter().copied())
            .collect();

        self.into_response(status as u16, None, &headers)
    }

    fn bad_request(self, msg: &str) -> anyhow::Result<()> {
        let mut response = self.into_cors_response(HttpStatus::BadRequest, &[])?;

        response.write(msg.as_bytes())?;

        Ok(())
    }
}

trait EspHttpServerExt {
    fn register_pna_handler<E, F>(
        &mut self,
        uri: &str,
        method: Method,
        handler: F,
    ) -> Result<&mut Self, EspError>
    where
        F: for<'r> Fn(Request<&mut EspHttpConnection<'r>>) -> Result<(), E> + Send + 'static,
        E: std::fmt::Debug;
}

impl EspHttpServerExt for EspHttpServer<'_> {
    fn register_pna_handler<E, F>(
        &mut self,
        uri: &str,
        method: Method,
        handler: F,
    ) -> Result<&mut Self, EspError>
    where
        F: for<'r> Fn(Request<&mut EspHttpConnection<'r>>) -> Result<(), E> + Send + 'static,
        E: std::fmt::Debug,
    {
        self.fn_handler(uri, Method::Options, handle_pna_preflight)?
            .fn_handler(uri, method, handler)
    }
}

fn handle_cert(req: Request<&mut EspHttpConnection>) -> anyhow::Result<()> {
    let headers = [
        ("Content-Type", "application/x-x509-ca-cert"),
        (
            "Content-Disposition",
            formatcp!("attachment; filename=\"{}\"", SERVER_CERT_NAME),
        ),
    ];

    let mut response = req.into_cors_response(HttpStatus::Ok, &headers)?;
    response.write(SERVER_CERT)?;

    Ok(())
}

pub struct Servers {
    pub https: EspHttpServer<'static>,
    pub http: EspHttpServer<'static>,
}

pub fn server_setup(sm: Arc<Mutex<ServoManager<'static>>>) -> Servers {
    let server_cert = X509::pem_until_nul(SERVER_CERT);
    let server_key = X509::pem_until_nul(SERVER_KEY);

    let https_config = HttpConfiguration {
        server_certificate: Some(server_cert),
        private_key: Some(server_key),
        ctrl_port: 32768,
        max_sessions: 3,
        ..Default::default()
    };

    let mut https_server =
        EspHttpServer::new(&https_config).expect("failed to create HTTPS server");

    let http_config = HttpConfiguration {
        http_port: 80,
        ctrl_port: 32769,
        ..Default::default()
    };

    let mut http_server = EspHttpServer::new(&http_config).expect("failed to create HTTP server");

    let mut servers = [&mut https_server, &mut http_server];
    for server in servers.iter_mut() {
        server
            .register_pna_handler("/", Method::Get, handle_index)
            .expect("failed to set home HTTP handler");

        server
            .register_pna_handler("/cert", Method::Get, handle_cert)
            .expect("failed to set cert HTTP handler");

        server
            .register_pna_handler("/config", Method::Get, move |req| handle_get_config(req))
            .expect("failed to set get-config HTTP handler");
        server
            .fn_handler("/config", Method::Post, move |mut req| {
                let body = read_body(&mut req, BODY_MAX_SIZE)?;
                handle_store_config(req, body)
            })
            .expect("failed to set store-config HTTP handler");

        let click_sm = sm.clone();
        server
            .register_pna_handler("/click", Method::Post, move |req| {
                handle_click(req, &click_sm)
            })
            .expect("failed to set click HTTP handler");

        let set_sm = sm.clone();
        server
            .register_pna_handler("/set", Method::Post, move |req| handle_set(req, &set_sm))
            .expect("failed to set set HTTP handler");

        let reset_sm = sm.clone();
        server
            .register_pna_handler("/reset", Method::Post, move |req| {
                handle_reset(req, &reset_sm)
            })
            .expect("failed to set reset HTTP handler");
    }

    log::info!(target: LOG_TAG, "web server running");

    Servers {
        https: https_server,
        http: http_server,
    }
}
