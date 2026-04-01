1. The Project StructureA standard Node.js setup usually looks like this:Plaintextmy-node-app/
├── index.js
├── package.json
├── package-lock.json
├── .dockerignore
└── Dockerfile
2. The Optimized Node.js DockerfileHere is a production-ready Dockerfile. It uses a non-root user for security and ensures efficient layer caching.Dockerfile# 1. Use the official Node.js LTS (Long Term Support) image
FROM node:20-slim

# 2. Set the working directory
WORKDIR /usr/src/app

# 3. Copy package files first
# This ensures 'npm install' only runs when dependencies change
COPY package*.json ./

# 4. Install dependencies
# 'npm ci' is faster and more reliable for production/automated builds
RUN npm ci --only=production

# 5. Copy the rest of the application code
COPY . .

# 6. Use a non-root user for security (provided by the official image)
USER node

# 7. Expose the port your app runs on
EXPOSE 3000

# 8. Start the application
CMD ["node", "index.js"]
3. Essential: The .dockerignore FileIn Node.js, this is mandatory. Without it, you will accidentally copy your local node_modules into the image, which can cause architecture mismatches and massive image sizes.Create a .dockerignore file:Plaintextnode_modules
npm-debug.log
.git
.env
4. Breakdown of Node-Specific CommandsCommandWhy we use it in Nodenode:20-slimProvides the Node runtime without the extra "bulk" of a full Debian OS.COPY package*.jsonThe wildcard * ensures we get both package.json and package-lock.json.npm ciStands for "Clean Install." It’s designed for CI/CD and Docker to ensure an exact match of your lockfile.USER nodeBy default, Docker runs as root. The Node image includes a safer node user to limit permissions.EXPOSE 3000Documentation for which port the container listens on at runtime.5. Build and Run CommandsStep A: BuildBashdocker build -t my-node-app .
Step B: RunNote the -p flag. This maps your computer's port 3000 to the container's port 3000.Bashdocker run -p 3000:3000 my-node-app
6. Pro-Tip: Hot Reloading (Development)If you are developing and don't want to rebuild the image every time you change a line of code, you can "mount" your local folder into the container using a Volume:Bashdocker run -p 3000:3000 -v $(pwd):/usr/src/app my-node-app
(Note: This requires you to have nodemon or a similar watcher in your package.json start script.)
