# Generate OpenVPN Config Files
From the documentation of kylemann/docker-openvpn it says that generating the config files is done with the following command:
`docker-compose run --rm openvpn ovpn_genconfig -u udp://live.technat.ch -C 'AES-256-CBC' -a 'SHA256'`

this generates the files "openvpn.conf" and "ovpn_env.sh" as well as a directory "ccd" in the folder that is specified as volume in the docker-compose file.

If we take a look at an example compose file:

```
version: '2'
services:
  openvpn:
    cap_add:
     - NET_ADMIN
    image: kylemanna/openvpn
    container_name: openvpn
    ports:
     - "1194:1194/udp"
    restart: always
    volumes:
     - ./openvpn-server/conf:/etc/openvpn
```
we can see that this volume is inside the conf folder and the conf folder is inside the service directory.

These files are allready in this repository as they are preconfigured.

### Preconfiguration to config files
in the openvpn.conf file I'm making the following changes:
- `server 192.168.255.0 255.255.255.0` -> 192.168.123.0/24 (not needed but i don't like it to be default)
- `push "dhcp-option DNS 8.8.8.8"` -> 208.67.222.222 (the dns servers you want to enforce your clients with)
- `push "dhcp-option DNS 8.8.4.4"` -> 208.67.220.220 (the dns servers you want to enforce your clients with)
- `push "block-outside-dns"` -> comment or delete line, not needed (used by to enforce dns on windows clients)
- `push "comp-lzo"` -> comment or delete line, not needed
- `comp-lzo no` -> comment or delete line, not needed
- `client-config-dir ccd` -> add somewhere, used to give static ips to clients
- `route 192.168.254.0 255.255.255.0` -> 192.168.222.0 255.255.255.0 move under client-config-dir line, defines basically range where staic ips are given to avoid interfearence with subnet given to openvpn server above
- `explicit-exit-notify 1` -> add at the end of file but only if you use UDP (which is default)

cause most of these settings are looked up in ovpn_env.sh I make these changes there too, according to what we did above:
- `declare -x OVPN_DISABLE_PUSH_BLOCK_DNS=0` -> 1
- `declare -x OVPN_DNS_SERVERS=([0]="8.8.8.8" [1]="8.8.4.4")` -> 208.67.222.222, 208.67.220.220
- `declare -x OVPN_SERVER=192.168.255.0/24` -> 192.168.123.0/24
- `declare -x OVPN_ROUTES=([0]="192.168.254.0/24")` -> 192.168.222.0/24

Some of these changes are just cosmetic (like the different ip adresses or dns servers) but others are necessary for static ip configurations or general improvment of the openvpn server.
I'm not an openvpn expert. I have some experience with it but if anyone sees how to improve these configurations feel free to do it.
