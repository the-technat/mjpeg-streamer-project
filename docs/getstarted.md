# Get Started
This guide shows how to initially setup the system

## Requirements
The requirements used for this project are split into skills/software and hardware

### Hardware
* Standard USB Webcam
* Raspberry Pi Model 4B with 2G RAM (recommended model)
* Raspberry Pi Case (maybe one with a power button)
* Power Supply for Raspberry Pi (at least 5V/3A)
* MicroSD Card for Raspberry Pi OS
* Cloud Server/VPS from any provider

#### Notes on hardware choices
* used a raspberry pi model 4b with 2g of memory, works fine in terms of performance. Think a Model 3B/3B+ too, any others have either no wifi or are maybe not powerfull enough (technically it works too)
* used a case with a power button for a dummy proof use of the raspberry pi so that everyone could use it
* used ubuntu 18.04 LTS as the os for the cloud server, but there everything is possible

### Skills/Software
* some experience with linux shell (this is not a dummy proof project!)
* computer with ssh client (nowadays even windows has a built-in ssh client)
* packages git,docker,docker-compose installed on cloud server
* raspberry pi os flashed to a sd card
* ssh into raspberry pi and install packages motion and openpn

## Installation of Raspberry Pi
I assume raspberry pi os is installed on a sd card and ssh is enabled. the packages listed in the Requirements are installed on the raspberry pi.

 

## Installation of back-end services
