# AHT20 Script

# Requirements:
pigpio-tools

# To use:
Source the script with:
`. aht20.sh` <br>
The init function will be called automatically.
## Read Humidity:
`aht20_readH` <br>

## Read Temperature:
`aht20_readT` <br>

## Read Temperature and convert to Fahrenheit:
`aht20_readT F` <br>

## When done, close the port with:
`aht20_close` <br>

# Known issues:
apt install pigpio-tools may not activate the daemon.
To enable the daemon at startup use:
```systemctl enable pigpiod
start pigpiod
```
The status check is rather naive and only checks the calibration needed bit once each read.

The CRC is read but not validated.
