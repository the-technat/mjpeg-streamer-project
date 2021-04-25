var MjpegProxy = require('mjpeg-proxy').MjpegProxy;
var express = require('express');
var https = require('https');
var http = require('http');
var fs = require('fs');
var path = require('path');

//read ssl certificate from file system (volume shared with certbot)
// var options = {
  // key: fs.readFileSync("/etc/letsencrypt/archive/live.technat.ch/privkey1.pem"),
  // cert: fs.readFileSync("/etc/letsencrypt/archive/live.technat.ch/fullchain1.pem"),
  // ca: fs.readFileSync("/etc/letsencrypt/archive/live.technat.ch/chain1.pem")
// };

var app = express()

app.use(express.static(path.join(__dirname, 'public')));

// app.get('/index1.jpg', new MjpegProxy('http://admin:admin@192.168.1.109/cgi/mjpg/mjpg.cgi').proxyRequest);

var server = http.createServer(app);
// var serverSSL = https.createServer(options, app);

server.listen(80);
// serverSSL.listen(443);
