1. The Project StructureEnsure your Ruby project is organized with the following files:Plaintextmy-ruby-app/
├── app.rb (or config.ru)
├── Gemfile
├── Gemfile.lock
├── .dockerignore
└── Dockerfile
2. The Ruby DockerfileHere is a solid, efficient Dockerfile for a Ruby application.Dockerfile# 1. Use an official Ruby image
FROM ruby:3.2-slim

# 2. Install system dependencies (essential for many Ruby gems)
# build-essential is needed for gems with C extensions
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# 3. Set the working directory
WORKDIR /app

# 4. Copy Gemfile and Gemfile.lock first
COPY Gemfile Gemfile.lock ./

# 5. Install gems
# --jobs 4 speeds up installation by using multiple cores
RUN bundle install --jobs 4

# 6. Copy the rest of the application
COPY . .

# 7. Start the application
CMD ["ruby", "app.rb"]
3. The .dockerignore for RubyTo keep your image clean and fast, ignore these common Ruby/Rails files:Plaintext.git
log/*.log
tmp/**/*
storage/**/*
.env
4. Key Concepts for Ruby DockerizationFeatureDescription-slim ImagesThese images are much smaller than the standard Ruby image, but they lack development tools. That is why we manually add build-essential in step 2.bundle installWe copy the Gemfile separately to ensure that Docker caches your gems. If you only change your code but not your gems, Docker skips this slow step.Native ExtensionsSome gems need C libraries to work. If you see an error during bundle install, you likely need to add a library (like libsqlite3-dev) via apt-get.5. Build and Run CommandsStep A: BuildBashdocker build -t my-ruby-app .
Step B: RunBashdocker run my-ruby-app
6. Pro-Tip: Running Rails?If you are running a Rails app specifically, you usually need to handle the server.pid file which can prevent a container from restarting. A common pattern is to use an entrypoint.sh script:Bash#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
In your Dockerfile, you would then add:DockerfileCOPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
Are you working on a simple Ruby script, or are you setting up a full web framework like Rails or Hanami?
