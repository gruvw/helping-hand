.PHONY: build run monitor

ard = "/home/gruvw/Applications/Arduino/bin/arduino-cli"

build:
	$(ard) compile

run:
	$(ard) compile
	$(ard) upload

monitor:
	$(ard) monitor -p /dev/ttyACM0 --config baudrate=115200
