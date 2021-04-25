#!/bin/bash
<<Header
Script:   addstaticroute.sh
Date:     30.05.2020
Author:   the-technat
Version:  0.1
History   User    Date        Change
          the-technat 30.05.2020  Initial Version 0.1
Description: in order for the proxy container to access the mjpeg streams, he needs a route configured via the openvpn server

Header

### Setup - read name of openvpn-server container and the subnet of the pi's connected to the openvpn-server

openvpnContainerName="openvpn-server"
toForwardSubnet="192.168.240.0/24"

### Lookup the internal ip address of the openvpn-server container
ipOfContainer=$(ping -c 1 $openvpnContainerName |egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" |sed -n 1p)

### Add route for proxy container
ip route add $toForwardSubnet via $ipOfContainer

#send a log to stdout
echo "Add static route $toForwardSubnet via $openvpnContainerName ($ipOfContainer)"
