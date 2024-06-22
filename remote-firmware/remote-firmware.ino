#include <Arduino.h>

#include "src/main/start.h"

void setup() {
    Serial.begin(115200);

    digitalWrite(RGB_BUILTIN, HIGH);  // Turn the RGB LED white
    delay(1000);
    digitalWrite(RGB_BUILTIN, LOW);  // Turn the RGB LED off
    delay(1000);

    neopixelWrite(RGB_BUILTIN, RGB_BRIGHTNESS, 0, 0);  // Red
    delay(1000);
    neopixelWrite(RGB_BUILTIN, 0, RGB_BRIGHTNESS, 0);  // Green
    delay(1000);
    neopixelWrite(RGB_BUILTIN, 0, 0, RGB_BRIGHTNESS);  // Blue
    delay(1000);
    neopixelWrite(RGB_BUILTIN, 0, 0, 0);  // Off / black
    delay(1000);

    start();
}

void loop() {
}
