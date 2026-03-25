node js code

1. app.js (Your code)


let http = require('http');

http.createServer(function (req, res) {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hello World!');
}).listen(8080);
console.log('Server running at http://localhost:8080/');

2. Dockerfile


# Use a lightweight Node.js image
FROM node:alpine    or node:14-slim

# Create a directory for your app
WORKDIR /usr/src/app

# Copy your local app.js into the container
COPY app.js .

# Expose the port your app runs on
EXPOSE 8080

# Start the application
CMD ["node", "app.js"]



Step 2: Build the Image
Open your terminal in that folder and run:


docker build -t nodeapp .



Step 3: Run the Container "Live"
To make the server accessible from your browser and keep it running in the background, use the -p (port mapping) and -d (detached) flags:


docker run -dit --restart always -p 8080:8080 --name nodeapp nodeapp

additional commands
sleep 1m or sleep 50s or 
