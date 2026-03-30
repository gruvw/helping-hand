# Roadmap

## Version 0.1.0

- [x] Mechanical design
    - [x] Working vice system with nut and bolt
    - [x] Modular vicer attachments system
    - [x] Provided vicers attachments
        - [x] Without attachments for regular straight remotes
        - [x] Small remotes rounded
        - [x] Tilted remotes, automatic angle
        - [x] Rubber material inserts for trickier remotes
    - [x] Modular rails attachment system (with provided double rails), both sides
    - [x] Modular servo module (with provided default servo module)
    - [x] Modular clippable arms system
    - [x] Provided arms
        - [x] 3 lengths
        - [x] Bendable arm design
    - [ ] New screws and reprint
- [x] Electronics
    - [x] Alimentation
    - [x] ESP32 C6
    - [x] Servo controller I2C
    - [x] Servo Motors
    - [x] Standalone systems (no PC connection)
- [x] Firmware (Rust)
    - [x] HTTP local webserver
    - [x] Motor control
    - [x] Basic button pressing interface
    - [ ] Basic new button setup interface
    - [ ] Hardcoded home WiFi credentials
- [ ] Software
    - [ ] Basic new button setup interface
    - [ ] Basic button pressing interface
    - [ ] HTTP security testing from Android IOS & desktops
- [ ] Documentation
    - [ ] Mechanical design modular parts schematics/drawings
    - [ ] Export necessary CAD files
    - [ ] Project README
    - [ ] GitHub release

## Version 1.0.0

- [ ] Mechanical design
    - [ ] Electronics enclosure with servo ports
    - [ ] Use square nuts designs (at least for rails)
    - [ ] Might want to use O rings for bolts (avoid plastic deformation)
    - [ ] Square bottom angle on servo attachment
    - [ ] Release downloads with custom tolerances
- [ ] Firmware
    - [ ] Refined communication protocol with main application
    - [ ] Button long press interface
    - [ ] Button double press interface
- [ ] Software
    - [ ] Full application with accessible design to control multiple devices
    - [ ] Set up procedure to configure new buttons/servos
    - [ ] Set up for new WiFi procedure full connection system config
- [ ] Evaluation
    - [ ] Stress test the system with long endurance testing for multiple days (find a way to record pressing intention and pressing success)
    - [ ] Evaluation of mechanical design for multiple remote types
    - [ ] Interface evaluation for ease of manipulation
- [ ] Documentation
    - [ ] Full CAD downloads

## Version 2.0.0

- [ ] Mechanical design
    - [ ] Try PETG for arms bending
    - [ ] Test Prusa printing at the end
- [ ] Electronics + Firmware
    - [ ] Captive portal for custom wifi setup
    - [ ] Automatic servo port detection
    - [ ] Small OLED status screen or LED
    - [ ] Push button for hardware actions (setup or reset)
- [ ] Firmware
    - [ ] Connection to Wi-Fi network from AP mode
- [ ] Software
    - [ ] Connection to Wi-Fi network from AP mode
    - [ ] Upload custom external lua scripts to the remotes for state control and custom endpoints
- [ ] Documentation
    - [ ] Web generator application tool for CAD parts (custom tolerances)

- [ ] IR replayer compatible module
