# mjpeg-streamer-project
mjpeg-streamer-project takes a standard USB webcam and sends the image of it to the web as an MJPEG stream

## Introduction
This project is created from an computer scientist in education and should be considered as a educational project.

It's about displaying a live video feed on a website. For this purpose the popular single board computer raspberry pi is used in combination with some back-end services running as docker containers on a server.

See the technical details for a more specific overview how the different components work together.

## Get Started
If you want to use this project for your education or want to try it out read the [Get Started Guide](/docs/getstarted.md) in the docs folder. There is describe what hardware / software is needed for this project and how to set it up initially.

## Technical Details
The following drawing shows up the flow of the image stream:

![overview - image](/docs/images/overview.jpg)

A Raspberry Pi using motion takes the image from a usb webcam and prepares it as an mjpeg stream. Motion provides this stream over http. To avoid bandwith problems of the raspberry pi and it's upstream connection to the internet, a mjpeg-proxy written in nodejs takes care of distributing the stream to the public. This proxy runs in a docker container on a cloud server and has therefore no bandwith problems. In order for the proxy to communicate with the raspberry pi, a VPN tunnel is created. This allows the pi to operate in any network because no port forwarding configurations need to be done on the firewall in front of the pi. But a VPN tunnel needs a VPN server. This is where openVPN-server comes in. It's another service running in a docker container and handling the connection to the raspberry pi. The proxy can just grab the stream through the VPN server.

## Contributing
This project is more of a one time project rather than a continuously developed project. If you have some ideas how to improve it, feel free to contact me, comment the project or fork it and create a pull request :)

## License
This project is published under the GNU General Public License v3.0

Some of the services used for my project are developed by other peoples. Thanks a lot for your awesome code!

* [docker-openVPN](https://github.com/kylemanna/docker-openvpn) is a openVPN sever in docker by kylemanna published under the MIT License
* [node-mjpeg-proxy](https://github.com/legege/node-mjpeg-proxy) is the origin source for the mjpeg-proxy by legege published under the GNU GPL-3.0 License
* [node-mjpeg-proxy](https://github.com/oxivanisher/node-mjpeg-proxy) containeraized mjpeg-proxy based on node-mjpeg-proxy, served as the base for my mjpeg-proxy and is published under the GNU GPL-3.0 License
* [docker-cron](https://hub.docker.com/r/gaafar/cron/) forms the base for the certbot, created by Gaafar published under the MIT License and further customized by David Herron in his blog post resulting in the certbot [Deploying an Express app with HTTPS support in Docker using Lets Encrypt SSL](https://techsparx.com/nodejs/docker/express-https.html)
