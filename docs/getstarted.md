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
I assume raspberry pi os is installed on a sd card and ssh is enabled. the packages listed in the Requirements are installed on the raspberry pi.

 Now what is left to do is enabling motion:  
 `sudo systemctl enable --now motion`

 and then configure it by editing it's config file:
 `sudo vim /etc/motion/motion.conf`

### Changes in motion config
The following things I like to change in motion
+----------------------+-------------------+---------------+----------------------------------------------------+
| Option               | default parameter | new parameter | description                                        |
+======================+===================+===============+====================================================+
| daemon               | off               | on            | allow motion to run in daemon mode                 |
+----------------------+-------------------+---------------+----------------------------------------------------+   
| videodevice          | /dev/video0       | /dev/video0   | depends on your cam and the number of\             |
|                      |                    |               | devices attachted to the pi,\                      |
|                      |                   |               | usually its /dev/video0                            |          
+----------------------+-------------------+---------------+----------------------------------------------------+
| V412_palette         | 17                | 15            | Pixel Format, must match the camera, \             |
|                      |                   |               | see `v4l2-ctl -V` command for details about your\  |
|                      |                   |               | cam you look for a code that looks like "YUYV" \   |
|                      |                   |               | which means 15, google for other codes             |
+----------------------+-------------------+---------------+----------------------------------------------------+
| width                | 320               | 1920          | depends on the max resolution of your camera       |
+----------------------+-------------------+---------------+----------------------------------------------------+
| heigth               | 240               | 1080          | depends on the max resolution of your camera       |
+----------------------+-------------------+---------------+----------------------------------------------------+
| framrate             | 2                 | 25            | effective framerate of stream, based on what your\ |
|                      |                   |               | cam can do, I recommend not going over the magic\  |
|                      |                   |               | border of 24/25                                    |
+----------------------+-------------------+---------------+----------------------------------------------------+
| stream_port          | 8081              | xxzyy         | port the stream is visiable, can be left default\  |
|                      |                   |               | or anything else, I usually use a high 6XXXX Port  |
+----------------------+-------------------+---------------+----------------------------------------------------+
| stream_maxrate       | 1                 | 30            | maximum fps the stream delivers, set the same as\  |
|                      |                   |               | the framrate option                                |
+----------------------+-------------------+---------------+----------------------------------------------------+
| stream_localhost     | on                | off           | enabled streaming over http with it's ip           |

I also enabled basic http authentication with http://username:password@192.168.210.1:8081 so that nobody inside the same network can access the stream without going over the proxy. But this is personal preference and totaly not necessary.

To make these changes take affect, restart the motion service:
`sudo systemctl restart motion`

If you now hit the the connection string (http://username:password@192.168.210.1:8081) in your browser you should see the stream and with it mjpeg is working inside your private network.

Now the back-end services need to be configured before a VPN connection can be setup.

## Installation of back-end services
The backend services need to run on a cloud server with docker and docker-compose installed.

If they are installed, the repository and with it the docker files can be downloaded:

```
git clone https://github.com/the-technat/mjpeg-streamer-project.git
cd mjpeg-stream-project/services
```

in the folder services there should be the docker-compose file and a file called .env which contains environment variables used by all of the services. Change them if necessary (if they are left unchanged, the ip adresses and names in the following commands should work too, else you need to change them)


### OpenVPN Server

#### Config & CA
OpenVPN needs some config files and a Certificate Authority to work. Luckily the docker image IF use for this project makes this very simple by just running some scripts inside a openvpn container:

The config files are allready generated and preconfigured in the repository. You can find them in the ./openvpn/conf folder.

If these files don't work with a newer version of the container image, there is a guide that shows how to regenerate these files and what is preconfigured. See [generate_ovpn_configfiles.md](./generate_ovpn_configfiles.md) for this guide.

So there is only the CA that has to be generated with the following command:

`docker-compose run --rm openvpn ovpn_initpki`

A password for the CA and a common name for it has to be entered.

!!Warning!! The Password for the CA should be keept very secure and be a safe one, because if someone get's this password he is master of your CA and therefore the strong encryption provided by OpenVPN is for nothing. A compromised CA is a hacked VPN!

Once the CA is there and your fine with the config files, start the openvpn-server finally:

`docker-compose up -d openvpn`

#### Client Configurations
Now the openvpn-server is running, a configuration file for the raspberry pi as a client can be generated
