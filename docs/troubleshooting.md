# Troubleshooting
A list of tipps and tricks what could be the problem if it does not work

## SSL is not working
if ssl fails to obtain the certifiacte check the following things:
- any firewall before the server doens't block **ingoing http(80) traffic**
- you exposed port 80 and 443 not only in the proxy.js but also in the Dockerfile at ./proxy/build/Dockerfile and in the docker-compose.yml
- check that the volumes that are crossmounted between the proxy and certbot match. If you create a file on the proxy at /etc/letsencrypt does it show in the /etc/letsencrypt of the certbot? Whats about the /webroots of the certbot? Are files there showing up in /app/public/.well-known of the proxy?
- its also a good idea to take a look at the source i've used to get ssl working: https://techsparx.com/nodejs/docker/express-https.html

## OpenVPN does not connect on the client
if the client won't connect to the openvpn there are some reasons that could cause:
- does the config file in /etc/openvpn end with .conf?
- what does `sudo systemctl status openvpn` tell you? That the process exited is normal but with exitcode 0 or something else?
- on linux remember these tree lines at the end of the config file to change dns:
  ```
  script-security 2
  up /etc/openvpn/update-resolv-conf
  down /etc/openvpn/update-resolv-conf
  ```
- check if the network your client is connected to allows outgoing 1194/udp traffic, maybe get a configfile for your mac / windows machine and try to connect from there.
- maybe a restart of the service does help: `sudo systemctl restart openvpn`
- `ifconfig` lists all current Network Interfaces, is there a nic named "tun0" or something like that?

## If I call the url of the proxy it says "cannot get"
If the proxy tells you in the browser he "can not get" that has something do to with the stream which is not reachable.
- enter a bash on your openvpn server and try to ping the client
- check if the client is connected to the vpn
- make sure the port you want to get the stream is correct
- in this line: `app.get('/index1.jpg', new MjpegProxy('http://admin:admin@192.168.1.109/cgi/mjpg/mjpg.cgi').proxyRequest);` the /index1.jpg means where your stream is reachable, so if your domain is "yourdomain.com" you have to add that behind so that it looks like "yourdomain.com/index1.jpg" you can of course change that to /
- `docker-compose logs -f` //All stuff that the containers print out on the "console" is saved into the docker logs
- see https://github.com/kylemanna/docker-openvpn/blob/master/docs/debug.md for debuging the openvpn
-
