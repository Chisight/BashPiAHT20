#!/bin/bash

num() {
  FS=" " read -ra numbers_array <<< "$ret"
  echo "${numbers_array[$1]}"
}

aht20_init() { #returns handle
  #open i2c port 1 device $38
  handle=$(pigs i2co 1 0x38 0)
  #send an init
  pigs I2CWD $handle 0xBE 0x08 0x00
  #(( $(aht20_status) & 4 )) #bit3 doesn't seem to set until request for temperature, so no status just return
  echo $handle
}

aht20_status() {
  pigs I2CWD $handle 0x71
  #read status
  ret=$(pigs i2crd $handle 1)
  num 1
}

aht20_close() {
  pigs I2CC $handle
}

aht20_prepRead() {
  pigs I2CWD $handle  0xAC 0x33 0x00
  while (( $(aht20_status) & 128 )); do
    :
  done
  if ! (( $(aht20_status) & 4 )); then #if not bit3, init and repeat
    pigs I2CWD $handle 0xBE 0x08 0x00
    while (( $(aht20_status) & 4 )); do
      :
    done
    pigs I2CWD $handle  0xAC 0x33 0x00
    while (( $(aht20_status) & 128 )); do
      :
    done
  fi
  pigs i2crd $handle 7
}

aht20_readH() {
  ret=$(aht20_prepRead)
  low4bits=$(($(num 4)/16))
  echo "scale=2; ((($(num 2) *256 + $(num 3))*16+ $low4bits) *100) / 1048576"|bc
}

aht20_readT() { #send F to get  fahrenheit.  otherwise celsius
  ret=$(aht20_prepRead)
  high4bits=$(($(num 4)%16))
  if [ "$1" == "F" ]; then
    echo "scale=2; (((($high4bits *256 + $(num 5))*256+ $(num 6)) )*200 / 1048576 -50)*9/5+32" |bc
  else
    echo "scale=2; ((($high4bits *256 + $(num 5))*256+ $(num 6)) )*200 / 1048576 -50" |bc
  fi
}


handle=$(aht20_init)


