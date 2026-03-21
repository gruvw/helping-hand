use esp_idf_hal::gpio::{InputPin, OutputPin};
use esp_idf_hal::i2c::{I2c, I2cConfig, I2cDriver};
use pwm_pca9685::{Address, Channel, Pca9685};

use crate::debug_println;

// properties of the servo
const SERVO_FREQUENCY: u32 = 50; // 50 Hz
const SERVO_ANGLE_MIN: f32 = 0.0;
const SERVO_ANGLE_MAX: f32 = 180.0;
const SERVO_ANGLE_MIN_TIME_MS: f32 = 0.5;
const SERVO_ANGLE_MAX_TIME_MS: f32 = 2.5;

// properties of the PCA9685
const PCA9685_FREQUENCY: u32 = 25_000_000; // 25 MHz
const PCA9685_RANGE: u32 = 4096; // 12 bits
const I2C_BAUD_RATE: u32 = 100_000; // 100kHz

// derived constants
const SERVO_PERIOD_MS: f32 = 1000.0 / SERVO_FREQUENCY as f32;
const SERVO_ANGLE_MIN_TICKS: u16 =
    (SERVO_ANGLE_MIN_TIME_MS / SERVO_PERIOD_MS * PCA9685_RANGE as f32).round() as u16;
const SERVO_ANGLE_MAX_TICKS: u16 =
    (SERVO_ANGLE_MAX_TIME_MS / SERVO_PERIOD_MS * PCA9685_RANGE as f32).round() as u16;

// prescale formula (PCA9685 datasheet 7.3.5)
// prescale = round(osc_clock / (4096 × update_rate)) − 1
const PCA9685_PRESCALE: u8 =
    (PCA9685_FREQUENCY as f32 / (PCA9685_RANGE * SERVO_FREQUENCY) as f32 - 1.0).round() as u8;

pub struct ServoManager<'a> {
    pca: Pca9685<I2cDriver<'a>>,
}

impl<'a> ServoManager<'a> {
    /// Initialises the I2C bus and PCA9685, ready to drive servos.
    pub fn new(
        i2c: impl I2c + 'a,
        sda: impl InputPin + OutputPin + 'a,
        scl: impl InputPin + OutputPin + 'a,
    ) -> Self {
        let config = I2cConfig::new().baudrate(I2C_BAUD_RATE.into());
        let driver =
            I2cDriver::new(i2c, sda, scl, &config).expect("failed to initialise I2C driver");

        let mut pca =
            Pca9685::new(driver, Address::default()).expect("failed to initialise PCA9685");
        pca.set_prescale(PCA9685_PRESCALE)
            .expect("failed to set PCA9685 prescale");
        pca.enable().expect("failed to enable PCA9685");

        debug_println!(
            "ServoManager: PCA9685 ready (prescale={})",
            PCA9685_PRESCALE
        );

        Self { pca }
    }

    /// Set angle for the given `channel`, angle is clamped between `SERVO_ANGLE_MIN` and
    /// `SERVO_ANGLE_MAX`.
    pub fn move_to_angle<I2C>(&mut self, channel: Channel, angle: f32)
    where
        I2C: embedded_hal::i2c::I2c,
    {
        let angle = angle.clamp(SERVO_ANGLE_MIN, SERVO_ANGLE_MAX);

        // linear interpolation between min and and max angles ticks
        let ticks = (SERVO_ANGLE_MIN_TICKS as f32
            + (angle - SERVO_ANGLE_MIN)
                * ((SERVO_ANGLE_MAX_TICKS - SERVO_ANGLE_MIN_TICKS) as f32
                    / (SERVO_ANGLE_MAX - SERVO_ANGLE_MIN)))
            .round() as u16;

        debug_println!("PCA9685: set channel {:?} to {}°", channel, angle);

        // signal goes high at time 0, goes low at time `ticks`
        self.pca
            .set_channel_on_off(channel, 0, ticks)
            .expect("failed to set PCA9685 channel on/off");
    }
}
