What’s a Dockerfile?

A Dockerfile is a text file with a series of instructions that Docker uses to build an image. You write commands like “use this base image,” “copy these files,” or “run this command,” and Docker follows them to create a runnable container.

Basic Structure and Commands

Here are the key instructions you’ll commonly use:

FROM: Specifies the base image to start with (e.g., Ubuntu, Node.js, Python).
 WORKDIR: Sets the working directory inside the container.
 COPY: Copies files from your local machine to the container.
 RUN: Executes commands during the build process (e.g., installing dependencies).
 CMD: Defines the default command to run when the container starts.
 EXPOSE: Indicates which port the container listens on (optional, for networking).



Step-by-Step Example 1: A Simple Python App

Let’s say you have a tiny Python app called app.py that prints "Hello, Docker!":

python

WrapCopy

# app.py
print("Hello, Docker!")

Here’s how to create a Dockerfile for it:

Dockerfile

WrapCopy

# Start with an official Python base image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the app.py file from your local directory to the container
COPY app.py /app/

# Specify the command to run the app
CMD ["python", "app.py"]

How to Build and Run It

Save the Dockerfile (no extension, just Dockerfile) and app.py in the same directory.

 Open a terminal in that directory and build the image:

 bash

WrapCopy

docker build -t my-python-app .



-t my-python-app names the image; . tells Docker to use the current directory.




 Run the container:

 bash

WrapCopy

docker run my-python-app

 Output: Hello, Docker!



What’s Happening?

FROM python:3.9-slim pulls a lightweight Python 3.9 image.

 WORKDIR /app sets /app as the directory for subsequent commands.

 COPY app.py /app/ moves your script into the container.

 CMD ["python", "app.py"] tells the container to execute your script when it starts.


Example 2: A Node.js Web Server

Now let’s try something slightly more complex—a simple Node.js app. Create a file called server.js:

javascript

WrapCopy

// server.js
const http = require('http');
const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello from Node.js!\n');
});
server.listen(3000, () => console.log('Server running on port 3000'));

And here’s the Dockerfile:

Dockerfile

WrapCopy

# Use an official Node.js base image
FROM node:16

# Set working directory
WORKDIR /usr/src/app

# Copy package.json (if you had one) and install dependencies
# For simplicity, we skip it here since there’s no package.json

# Copy the server.js file
COPY server.js .

# Expose port 3000
EXPOSE 3000

# Run the app
CMD ["node", "server.js"]

Build and Run

Save Dockerfile and server.js in the same directory.

 Build the image:

 bash

WrapCopy

docker build -t my-node-app .




 Run the container, mapping port 3000 to your local machine:

 bash

WrapCopy

docker run -p 3000:3000 my-node-app




 Open your browser to http://localhost:3000—you’ll see "Hello from Node.js!"



Explanation

FROM node:16 uses Node.js version 16.

 EXPOSE 3000 documents that the app uses port 3000 (though it doesn’t actually publish it—-p does that).

 CMD ["node", "server.js"] starts the server.


Example 3: Installing Dependencies

What if your app needs dependencies? Let’s modify the Python example to use a requirements.txt file. Create:

txt

WrapCopy

# requirements.txt
requests==2.28.1

Update app.py:

python

WrapCopy

# app.py
import requests
print("Hello, Docker!")
print(requests.get("https://api.github.com").status_code)

And the Dockerfile:

Dockerfile

WrapCopy

FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
CMD ["python", "app.py"]

Build and Run

Build: docker build -t my-python-app-with-deps .

 Run: docker run my-python-app-with-deps Output: Hello, Docker! followed by 200 (HTTP status from GitHub).



Key Addition

RUN pip install -r requirements.txt installs the requests library during the build.


Tips for Writing Dockerfiles

Order Matters: Put commands that change less frequently (like FROM or RUN for dependencies) higher up—Docker caches layers to speed up builds.

 Keep It Small: Use slim or minimal base images (e.g., python:3.9-slim instead of python:3.9) to reduce image size.

 One Command per RUN: Combine commands with && (e.g., RUN apt-get update && apt-get install -y curl) to minimize layers.

