use core::time::Duration;

use base64::{Engine as _, engine::general_purpose::URL_SAFE_NO_PAD};
use esp_idf_hal::delay::TickType;
use esp_idf_hal::gpio::{InputPin, OutputPin};
use esp_idf_hal::rmt::config::{
    CarrierConfig, DutyPercent, ReceiveConfig, RxChannelConfig, TransmitConfig, TxChannelConfig,
};
use esp_idf_hal::rmt::encoder::CopyEncoder;
use esp_idf_hal::rmt::{
    ClockSource, PinState, PulseTicks, RmtChannel, RxChannelDriver, Symbol, TxChannelDriver,
};
use esp_idf_hal::units::{FromValueType, Hertz};

const LOG_TAG: &str = "IrManager";

const CARRIER_FREQ_HZ: u32 = 38_000;
const CARRIER_DUTY: f32 = 0.33;

const RMT_RESOLUTION: Hertz = Hertz(1_000_000);
const RMT_CLOCK_SOURCE: ClockSource = ClockSource::XTAL;
const RX_RESOLUTION: Hertz = Hertz(200_000);
const RX_SIGNAL_MIN: Duration = Duration::from_nanos(5_000);
const RX_SIGNAL_MAX: Duration = Duration::from_millis(100);
const RX_TIMEOUT: Duration = Duration::from_secs(5);

const MAX_RX_SYMBOLS: usize = 512;

pub struct IrManager<'a> {
    tx: TxChannelDriver<'a>,
    rx: RxChannelDriver<'a>,
}

impl<'a> IrManager<'a> {
    pub fn new(rx_pin: impl InputPin + 'a, tx_pin: impl OutputPin + 'a) -> Self {
        let tx_config = TxChannelConfig {
            clock_source: RMT_CLOCK_SOURCE,
            resolution: RMT_RESOLUTION,
            ..Default::default()
        };
        let mut tx = TxChannelDriver::new(tx_pin, &tx_config)
            .expect("Failed to initialize IR TX RMT channel");

        let carrier = CarrierConfig {
            frequency: CARRIER_FREQ_HZ.Hz(),
            duty_cycle: DutyPercent::new(CARRIER_DUTY).expect("valid duty percent"),
            ..Default::default()
        };
        tx.apply_carrier(Some(&carrier))
            .expect("Failed to apply IR carrier config");

        let rx_config = RxChannelConfig {
            clock_source: RMT_CLOCK_SOURCE,
            resolution: RX_RESOLUTION,
            ..Default::default()
        };
        let rx = RxChannelDriver::new(rx_pin, &rx_config)
            .expect("Failed to initialize IR RX RMT channel");

        log::info!(target: LOG_TAG, "IR Manager (RMT-backed) successfully initialized.");

        Self { tx, rx }
    }

    pub fn ir_receive(&mut self) -> String {
        let mut symbols = vec![Symbol::default(); MAX_RX_SYMBOLS];

        let receive_config = ReceiveConfig {
            signal_range_min: RX_SIGNAL_MIN,
            signal_range_max: RX_SIGNAL_MAX,
            timeout: Some(TickType::from(RX_TIMEOUT).ticks()),
            ..Default::default()
        };

        let received = match self.rx.receive(&mut symbols, &receive_config) {
            Ok(count) => count,
            Err(e) => {
                if e.code() != esp_idf_sys::ESP_ERR_TIMEOUT {
                    log::warn!(target: LOG_TAG, "IR RX error: {:?}", e);
                }
                return String::new();
            }
        };

        let mut durations: Vec<u32> = Vec::with_capacity(received * 2);
        for symbol in &symbols[..received] {
            durations.push(symbol.level0().ticks.duration(RX_RESOLUTION).as_micros() as u32);
            durations.push(symbol.level1().ticks.duration(RX_RESOLUTION).as_micros() as u32);
        }

        let mut bytes = Vec::with_capacity(durations.len() * 4);
        for value in durations {
            bytes.extend_from_slice(&value.to_le_bytes());
        }

        URL_SAFE_NO_PAD.encode(bytes)
    }

    pub fn ir_replay(&mut self, data: &str) {
        let bytes = match URL_SAFE_NO_PAD.decode(data) {
            Ok(b) => b,
            Err(e) => {
                log::warn!(target: LOG_TAG, "Failed to decode IR base64 payload: {:?}", e);
                return;
            }
        };

        if bytes.is_empty() || bytes.len() % 4 != 0 {
            log::warn!(
                target: LOG_TAG,
                "IR payload has invalid length: {} bytes",
                bytes.len()
            );
            return;
        }

        let buffer: Vec<u32> = bytes
            .chunks_exact(4)
            .map(|chunk| u32::from_le_bytes([chunk[0], chunk[1], chunk[2], chunk[3]]))
            .collect();

        let mut symbols = Vec::with_capacity(buffer.len().div_ceil(2));

        let max_pulse_us = PulseTicks::max().duration(RMT_RESOLUTION).as_micros() as u32;

        for pair in buffer.chunks(2) {
            let mark_us = pair[0].min(max_pulse_us);
            let space_us = pair.get(1).copied().unwrap_or(0).min(max_pulse_us);

            match Symbol::new_with(
                RMT_RESOLUTION,
                PinState::High,
                Duration::from_micros(mark_us as u64),
                PinState::Low,
                Duration::from_micros(space_us as u64),
            ) {
                Ok(symbol) => symbols.push(symbol),
                Err(e) => {
                    log::warn!(target: LOG_TAG, "Skipping invalid IR pulse pair: {:?}", e);
                }
            }
        }

        if symbols.is_empty() {
            return;
        }

        let encoder = match CopyEncoder::new() {
            Ok(e) => e,
            Err(e) => {
                log::warn!(target: LOG_TAG, "Failed to create IR copy encoder: {:?}", e);
                return;
            }
        };

        let transmit_config = TransmitConfig::default();

        if let Err(e) = self.tx.send_and_wait(encoder, &symbols, &transmit_config) {
            log::warn!(target: LOG_TAG, "IR TX failed: {:?}", e);
        }
    }
}

// SAFETY: IrManager only wraps ESP-IDF RMT channel drivers. The underlying
// ESP-IDF RMT driver calls (tx send, rx receive) are safe to invoke from any
// FreeRTOS task: they are not pinned to the thread/task that created the
// channel. Access to IrManager is always serialized externally via a Mutex
// (see server.rs), so there's no possibility of concurrent hardware access.
unsafe impl Send for IrManager<'_> {}
