FROM node

# Proxy is accessed by the public, use default ports for http and https
EXPOSE 80
EXPOSE 443

# create a place for our app
WORKDIR /app
RUN mkdir public

# copy files into the container
COPY addstaticroute.sh addstaticroute.sh
COPY node-mjpeg-proxy-master node-mjpeg-proxy-master

#install "dependency's" for mjpeg-proxy
RUN npm install express express-force-ssl

#install mjpeg-proxy module
RUN npm install ./node-mjpeg-proxy-master

# define init process
ENTRYPOINT ./addstaticroute.sh && node ./proxy.js
