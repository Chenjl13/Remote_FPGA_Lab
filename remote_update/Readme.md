# The introduction of remote update

## Remote update concept

FPGA remote update means that using internet to update the hardware logic configuration of FPGA without exposing to the device physically. As a programmable chip, FPGA achieve its function by uploading specific configuration file. Conventional upgrade needs physical IO(like JTAG) to flash, while remote update leverages communication module(like Ethernet, 4G/5G or WIFI) to transmit the configuration file to the objected device, receiving and carrying out update process by micro control unit, thereby adjusting hardware function dynamically.

## The interpretation of relevant concepts

- Warm Start: Dynamically configuring FPGA logic without powering off.
- Golden Bitstream: Like the "Secure Image" of system, golden bitstream is used to upload into FPGA and restore its basic function when the system meets some failure.
- Application Data Bitstream: It is written by users for achieving different functions, including practical function logic(Like algorithm acceleration, protocal process, real-time control). It is the configured version of dynamic generation, update and switching according to users' needs.



