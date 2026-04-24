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
    - [x] New longger screws and reprint
- [x] Electronics
    - [x] Alimentation
    - [x] ESP32 C6
    - [x] Servo controller I2C
    - [x] Servo Motors
    - [x] Standalone systems (no PC connection)
- [x] Firmware (Rust)
    - [x] HTTP local webserver
    - [x] Motor control
    - [x] Basic button pressing interface (click)
    - [x] Basic new button setup interface (set + reset)
    - [x] Hardcoded home Wi-Fi credentials
    - [x] Option to run Wi-Fi as AP mode
    - [x] Wi-Fi reconnection system
    - [x] Persisted config store on device + get endpoint
- [x] Software
    - [x] GitHub CI
    - [x] HTTP and web security exploration
    - [x] Basic local DB
    - [x] HTTP security testing and mDNS queries from Android & IOS & desktop
    - [x] New remote registration interface
    - [x] Basic new button setup interface
    - [x] Basic button pressing interface
- [x] Documentation
    - [x] GitHub release
    - [x] Demo video

## Version 1.0.0

- [ ] Mechanical design
    - [x] Wider base
    - [x] Electronics enclosure with servo ports
    - [x] Use square nuts designs (at least for rails)
    - [ ] Might want to use O rings for bolts (avoid plastic deformation)
    - [x] Square bottom angle on servo attachment
    - [ ] Small user fillets
- [ ] Firmware
    - [ ] Refined communication protocol with main application
- [ ] Software
    - [ ] Remove and rename remote action interface
    - [ ] Folder and tiles system
    - [ ] Application logo
    - [x] New remote device interface
    - [x] Full set up procedure to configure new buttons/servos
    - [ ] Persisted buttons config from app
    - [ ] Full application with accessible mode design to control multiple devices
        - [ ] Auto cycling mode
        - [ ] Press for next mode
    - [ ] Settings page for configuration
- [ ] Evaluation
    - [ ] Stress test the system with long endurance testing for multiple days (find a way to record pressing intention and pressing success)
    - [ ] Evaluation of mechanical design for multiple remote types
    - [ ] Interface evaluation for ease of manipulation
    - [ ] Real world integration testing with measurements
- [ ] Documentation
    - [ ] Mechanical design modular parts schematics/drawings
    - [ ] Full CAD downloads
    - [ ] Project README
    - [ ] GitHub release

## Version 2.0.0

- [ ] Mechanical design
    - [ ] Release downloads with custom tolerances
    - [ ] Try PETG for arms bending
    - [ ] Test Prusa printing at the end
    - [ ] Smaller area under for electronics, might require custom PCB
    - [ ] Two sizes variants (currently one size fits all, so large)
- [ ] Electronics + Firmware
    - [ ] Automatic servo port detection
    - [ ] Small OLED status screen or LED
    - [ ] Push button for hardware actions (setup or reset)
- [ ] Firmware
    - [ ] Connection to Wi-Fi network from AP mode
    - [ ] Captive portal for custom wifi setup
    - [ ] Button double press interface
    - [ ] More complex button systems, like press sequences
- [ ] Software
    - [ ] Button long press interface
    - [ ] Connection to Wi-Fi network from AP mode
    - [ ] Upload custom external lua scripts to the remotes for state control and custom endpoints
    - [ ] i18n
    - [ ] Multiple application profiles if you go to your friend's house for eample
    - [ ] Recently used tile
    - [ ] Custom tiles ordering
- [ ] Documentation
    - [ ] Web generator application tool for CAD parts (custom tolerances)

- [ ] IR replayer compatible module
