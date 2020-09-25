FROM node

# Proxy is accessed by the public, use default ports for http and https
EXPOSE 80
EXPOSE 443

# create a place for our app
WORKDIR /app

#install dependency for mjpeg-proxy
RUN npm install express express-force-ssl

# copy files into the container
COPY addstaticroute.sh .
COPY proxy.js .

# define cmd
CMD [ sh -c "addstaticroute.sh && node ./proxy.js"]
