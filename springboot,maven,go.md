🌱 Spring Boot (Maven)
dockerfileFROM maven:3.9-openjdk-17
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY . .
RUN mvn package -DskipTests
CMD ["java", "-jar", "target/app.jar"]

🌱 Spring Boot (Gradle)
dockerfileFROM gradle:8.5-jdk17
WORKDIR /app
COPY build.gradle .
RUN gradle dependencies
COPY . .
RUN gradle build -x test
CMD ["java", "-jar", "build/libs/app.jar"]

🐘 Maven (Plain Java)
dockerfileFROM maven:3.9-openjdk-17
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn compile
CMD ["mvn", "exec:java"]

🐘 Gradle (Plain Java)
dockerfileFROM gradle:8.5-jdk17
WORKDIR /app
COPY build.gradle .
COPY settings.gradle .
RUN gradle dependencies
COPY . .
CMD ["gradle", "run"]

🍃 Spring Boot Multi-Stage (Production Ready ⚡)
dockerfile# Stage 1 - Build
FROM maven:3.9-openjdk-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

# Stage 2 - Run
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=builder /app/target/app.jar app.jar
CMD ["java", "-jar", "app.jar"]

🐍 Django (Python)
dockerfileFROM python:3.11-alpine
WORKDIR /app
COPY requirements.txt .
RUN pip install django gunicorn
COPY . .
RUN python manage.py collectstatic --noinput
CMD ["gunicorn", "myproject.wsgi:application"]

⚡ FastAPI (Python)
dockerfileFROM python:3.11-alpine
WORKDIR /app
COPY requirements.txt .
RUN pip install fastapi uvicorn
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

💎 Rails (Ruby)
dockerfileFROM ruby:3.2
WORKDIR /app
COPY Gemfile .
RUN bundle install
COPY . .
RUN rails assets:precompile
CMD ["rails", "server", "-b", "0.0.0.0"]

🐘 Laravel (PHP)
dockerfileFROM php:8.2-cli
WORKDIR /app
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY composer.json .
RUN composer install
COPY . .
CMD ["php", "artisan", "serve", "--host=0.0.0.0"]

⚡ Next.js (React)
dockerfileFROM node:18-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build
CMD ["npm", "start"]

🔷 Angular
dockerfileFROM node:18-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build
CMD ["npx", "http-server", "dist/app"]

⚡ Vue.js
dockerfileFROM node:18-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build
CMD ["npx", "http-server", "dist"]

🦀 Rust (Actix Web)
dockerfileFROM rust:1.75
WORKDIR /app
COPY Cargo.toml .
RUN cargo fetch
COPY . .
RUN cargo build --release
CMD ["./target/release/app"]

🐹 Go (Gin Framework)
dockerfileFROM golang:1.21
WORKDIR /app
COPY go.mod go.sum .
RUN go mod download
COPY . .
RUN go build -o main .
CMD ["./main"]
