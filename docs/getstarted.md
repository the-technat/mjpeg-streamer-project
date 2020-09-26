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
* one or to IPv4 A DNS records pointing to your server (used by openvpn and the proxy to connect to the stream)

## Prepare Raspberry Pi to as mjpeg-streamer
I assume raspberry pi os is installed and configured including the packages from the requirements installed.

If you have no experience with raspberry pi's I recommend you reading my guide about [installing Raspberry Pi OS](https://technat.ch/de/blog/install-raspberrypios) and also my guide about [default raspberry pi config](https://technat.ch/de/blog/configure-raspberry-pi-os) to get started with it.

 Now what is left to do is enabling motion:  
 `sudo systemctl enable --now motion`

 and then configure it by editing it's config file:
 `sudo vim /etc/motion/motion.conf`

### Changes in motion config
The following things I like to change in motion
| Option               | default parameter | new parameter | description                  |
| -------------------- | ----------------- | ------------- | ---------------------------- |
| daemon               | off               | on            | allow motion to run in daemon mode |
| videodevice          | /dev/video0       | /dev/video0   | depends on your cam and the number of <br /> devices attachted to the pi, usually it's /dev/video0 |
| V412_palette         | 17                | 15            | Pixel Format, must match the camera, see `v4l2-ctl -V` <br /> command for details about your cam <br /> you look for a code that looks like "YUYV" <br /> which means 15, google for other codes |
| width                | 320               | 1920          | depends on the max resolution of your camera |
| heigth               | 240               | 1080          | depends on the max resolution of your camera |
| framrate             | 2                 | 25            | effective framerate of stream, based on what your cam can do, <br /> I recommend not going over the magic border of 24/25 |
| stream_port          | 8081              | xxzyy         | port the stream is visiable, can be left default or anything else, <br /> I usually use a high 6XXXX Port |
| stream_maxrate       | 1                 | 30            | maximum fps the stream delivers, set the same as the framrate option |
| stream_localhost     | on                | off           | enabled streaming over http with it's ip |
| stream_auth_method   | 0                 | 1             | set the authentication method to http basic auth |
| stream_authentication | commented        | username:password | define a username and password <br />used to access the stream |

I like enabling basic http authentication so that nobody inside the same network can access the stream without going over the proxy. But this is personal preference and totally not necessary.

Now edit /etc/default/motion and set the `start_motion_daemon=no` to `yes` to make sure motion is allowed to run in daemon mode

Finally restart motion service for the changes to take affect:
`sudo systemctl restart motion`

If you now hit the the connection string (http://username:password@192.168.210.1:8081) in your browser you should see the mjpeg stream.

The next step would be to to join the raspberry pi into the VPN but for that the VPN server needs to run.

## Fire up openvpn-server
Steps to Do:
* ajust domain in services/openvpn-server/conf/openvpn.conf and services/openvpn-server/ovpn.env.sh and other settings if liked
* fix permissions on openvpn config files chmod 644 for root
* initpki (maybe hotfix if https://github.com/kylemanna/docker-openvpn/issues/605 is still open)
* start the openvpn service finally in detached mode and see the logs

As VPN Protocol I use OpenVPN.

I assume the packages from the requirements are installed on your server and you are logged in to the server.

Then the repository and with it the docker files can be cloned:

```
git clone https://github.com/the-technat/mjpeg-streamer-project.git
cd mjpeg-stream-project/services
```

// in the folder services there should be the docker-compose file and a file called .env which contains ////// environment variables used by all of the services. Change them if necessary (if they are left unchanged, // the ip adresses and names in the following commands should work too, else you need to change them)


#### Config Files
OpenVPN needs some config files and a Certificate Authority to work. Luckily the docker image used for this project makes this very simple by just running some scripts inside container. The config files are already generated and preconfigured in the repository. You can find them in the ./openvpn-server/conf folder.

If these files don't work with a newer version of the container image, there is a guide that shows how to regenerate these files and what is preconfigured. See [generate_ovpn_configfiles.md](./generate_ovpn_configfiles.md).

### CA
The CA can be initialized with the following command:
`docker-compose run --rm openvpn ovpn_initpki`


Note: currently there is an open issue on the docker-openvpn image: [https://github.com/kylemanna/docker-openvpn/issues/605](https://github.com/kylemanna/docker-openvpn/issues/605). If the issue is closed, it can be ignored, but as long as it is open, the following command needs to be executed before the CA is initialized:

`docker-compose run --rm openvpn touch /etc/openvpn/vars`

A password for the CA and a common name for it has to be entered during the initialization

!!Warning!! The Password for the CA should be keept very secure and be a safe one, because if someone get's this password he is master of your CA and therefore the strong encryption provided by OpenVPN is for nothing. A compromised CA is a hacked VPN!

Once the CA is initialized and your fine with the config files, start the openvpn-server finally with:
`docker-compose up -d openvpn`

## VPN Client Configuration
Now the openvpn-server is running, a configuration file for the raspberry pi as a client can be generated.

First set a variable to avoid tipping errors:
`export CLIENTNAME="your_client_name"`
then create a config file:
`docker-compose run --rm openvpn easyrsa build-client-full $CLIENTNAME nopass`
since the VPN has to be established automatically we can not enter a passwort each time. There are solutions to sill pass the password in automatically but it is easier without. If really needed remove `nopass`.
now get the clientconfig file out of the container:
`docker-compose run --rm openvpn ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn`
it should be located in the current directory. I recommend to store them at ./openvpn-server/clients/ or copy them to the client and delete.

### set static ip for client
Because the proxy needs to access the raspberry pi through the VPN, the client needs a static ip address. To do this create a file in the ./openvpn-server/conf/ccd folder and name it excatly like the $CLIENTNAME without any file ending.

The content should be the following:
```
`ifconfig-push 192.168.240.49 192.168.240.50`
```

The ip's should be selected from this list of couples:

[  1,  2] [  5,  6] [  9, 10] [ 13, 14] [ 17, 18]
[ 21, 22] [ 25, 26] [ 29, 30] [ 33, 34] [ 37, 38]
[ 41, 42] [ 45, 46] [ 49, 50] [ 53, 54] [ 57, 58]
[ 61, 62] [ 65, 66] [ 69, 70] [ 73, 74] [ 77, 78]
[ 81, 82] [ 85, 86] [ 89, 90] [ 93, 94] [ 97, 98]
[101,102] [105,106] [109,110] [113,114] [117,118]
[121,122] [125,126] [129,130] [133,134] [137,138]
[141,142] [145,146] [149,150] [153,154] [157,158]
[161,162] [165,166] [169,170] [173,174] [177,178]
[181,182] [185,186] [189,190] [193,194] [197,198]
[201,202] [205,206] [209,210] [213,214] [217,218]
[221,222] [225,226] [229,230] [233,234] [237,238]
[241,242] [245,246] [249,250] [253,254]

These couples refer to the last octet of the 192.168.240.0/24 net.

see [https://openvpn.net/community-resources/how-to/#pushing-dhcp-options-to-clients](https://openvpn.net/community-resources/how-to/#pushing-dhcp-options-to-clients) for more details.

### Changes to client file

Now this config file needs some changs in order for it to succesfully change dns settings on linux. If this config file is used on windows or mac, these changes are not required.

```
script-security 2
up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
```

These lines need to go at the very bottom of the file.

### Copy file to raspberry pi

Now the file can be copied to the raspberry pi. One solution for this is to use SCP:

`scp username@yourserver:/path/to/project-dir/openvpn/conf/clients/client.ovpn .`

Or use SFTP

```
sftp username@yourserver
cd /path/to/project-dir/openvpn/conf/clients/
get client.ovpn
exit
```

### Activate openvpn config
To use this config file it needs to be placed in /etc/openvpn and it's name should be openvpn.conf:

`sudo mv client.ovpn /etc/openvpn/openvpn.conf`

and the service openvpn needs to be enabled and started:

`sudo systemctl enable --now openvpn`

### check connection
If you hit a `ifconfig` you should see a new network interface named "tunX"

You can also run a `docker-compose logs -f` on the server to see if the client is connected.

## Fire up Proxy
To Do:
* 
