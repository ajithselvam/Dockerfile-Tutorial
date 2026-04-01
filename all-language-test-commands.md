1. Python (Testing with pytest)
Assuming you have pytest in your requirements.txt.

Run tests inside a new container:

Bash
docker run --rm my-python-app pytest
Run tests in a currently running container:

Bash
docker exec <container_id> pytest
2. Node.js (Testing with npm test)
Most Node apps use jest or mocha defined in the package.json scripts.

Run the test script:

Bash
docker run --rm my-node-app npm test
Run tests in "watch" mode (requires volume mounting):

Bash
docker run -it -v $(pwd):/usr/src/app my-node-app npm test -- --watch
3. Ruby (Testing with rspec or minitest)
Run RSpec tests:

Bash
docker run --rm my-ruby-app bundle exec rspec
Run Rails-specific tests:

Bash
docker run --rm my-ruby-app bin/rails test
4. Java (Testing with Maven/Gradle)
In the multi-stage Dockerfile I provided, we skipped tests during the build (-DskipTests). To run them specifically:

Using Maven:

Bash
docker run --rm my-java-app mvn test
Using Gradle:

Bash
docker run --rm my-java-app ./gradlew test
Note: Since the "Run" stage of the Java Dockerfile uses a JRE (which lacks build tools), you may need to run these commands against the build stage or a dedicated development image.

Generic Docker "Health Check" Commands
Regardless of the language, use these commands to verify the container is healthy:

1. Check if the container is running
Bash
docker ps
2. Inspect the Logs
If your app crashed on startup, the logs will tell you why (e.g., missing environment variables or syntax errors).

Bash
docker logs <container_name_or_id>
3. Interactive Shell (The "Look Around" Test)
If you need to see if files were copied correctly to the right folder:

Bash
docker run -it my-app-name /bin/sh
# Or for images with bash:
docker run -it my-app-name /bin/bash
4. Network Test (Curl)
If your app is a web server (Node/Python/Java/Ruby) running on port 8080:

Bash
curl localhost:8080
