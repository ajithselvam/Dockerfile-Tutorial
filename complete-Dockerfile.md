# 🎯 Docker Best Practices Deep Dive

## Table of Contents
1. [Image Optimization](#image-optimization)
2. [Security Best Practices](#security-best-practices)
3. [Performance Optimization](#performance-optimization)
4. [Development Workflow](#development-workflow)
5. [Production Deployment](#production-deployment)
6. [Troubleshooting](#troubleshooting)

---

## Image Optimization

### 1. Choose the Right Base Image

#### Size Comparison
```dockerfile
# ❌ Large: ~1GB
FROM python:3.11

# ✅ Better: ~180MB
FROM python:3.11-slim

# ✅ Smallest: ~50MB (but may lack dependencies)
FROM python:3.11-alpine
```

#### When to Use Each

**Full Image (`python:3.11`)**
- Development environments
- When you need many system packages
- Quick prototyping

**Slim Image (`python:3.11-slim`)**
- Production applications (recommended)
- Balance between size and compatibility
- Most common use case

**Alpine Image (`python:3.11-alpine`)**
- Minimal footprint required
- Simple applications
- Note: Uses musl instead of glibc (compatibility issues possible)

### 2. Multi-Stage Builds

Multi-stage builds can reduce image size by 50-90%.

#### Example: Node.js Application
```dockerfile
# ❌ Single stage: ~500MB
FROM node:20
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
CMD ["npm", "start"]

# ✅ Multi-stage: ~150MB
FROM node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/server.js"]
```

### 3. Layer Optimization

#### Order Layers by Change Frequency
```dockerfile
FROM python:3.11-slim

# 1. System packages (rarely change)
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 2. Application dependencies (change occasionally)
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Application code (changes frequently)
COPY . .

CMD ["python", "app.py"]
```

#### Combine Related Commands
```dockerfile
# ❌ Multiple layers
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get install -y package2
RUN rm -rf /var/lib/apt/lists/*

# ✅ Single optimized layer
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*
```

### 4. .dockerignore File

Always create a `.dockerignore` to exclude unnecessary files:

```
# Version control
.git
.gitignore
.gitattributes

# Dependencies
node_modules
venv
__pycache__
*.pyc
.pytest_cache

# IDE
.vscode
.idea
*.swp
*.swo

# Documentation
*.md
README
LICENSE

# Environment
.env
.env.local
*.log

# Build artifacts
dist
build
target
*.jar
*.war

# OS files
.DS_Store
Thumbs.db

# Test files
tests
__tests__
*.test.js
*.spec.js
coverage

# CI/CD
.github
.gitlab-ci.yml
Jenkinsfile

# Docker
Dockerfile*
docker-compose*.yml
.dockerignore
```

### 5. Remove Package Manager Cache

```dockerfile
# Python
RUN pip install --no-cache-dir -r requirements.txt

# Node.js
RUN npm ci --only=production && npm cache clean --force

# Apt
RUN apt-get update && apt-get install -y package \
    && rm -rf /var/lib/apt/lists/*

# Apk (Alpine)
RUN apk add --no-cache package

# Yum
RUN yum install -y package && yum clean all
```

---

## Security Best Practices

### 1. Run as Non-Root User

```dockerfile
# ❌ Running as root (default)
FROM python:3.11-slim
WORKDIR /app
COPY . .
CMD ["python", "app.py"]

# ✅ Running as non-root user
FROM python:3.11-slim
WORKDIR /app
COPY . .

# Create user
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

CMD ["python", "app.py"]
```

#### For Alpine-based Images
```dockerfile
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser && \
    chown -R appuser:appuser /app

USER appuser
```

### 2. Never Store Secrets in Images

```dockerfile
# ❌ NEVER DO THIS
ENV API_KEY=sk-1234567890
ENV DATABASE_PASSWORD=mysecretpassword

# ✅ Use environment variables at runtime
# docker run -e API_KEY=sk-1234567890 myapp

# ✅ Or use Docker secrets
# docker secret create api_key /path/to/secret
```

### 3. Use Official Base Images

```dockerfile
# ✅ Official images from Docker Hub
FROM python:3.11-slim
FROM node:20-alpine
FROM postgres:15

# ❌ Avoid unknown/unmaintained images
FROM randomuser/python
```

### 4. Specify Exact Versions

```dockerfile
# ❌ Unpredictable
FROM python:latest
FROM node

# ✅ Specific and reproducible
FROM python:3.11.7-slim
FROM node:20.10.0-alpine
```

### 5. Scan Images for Vulnerabilities

```bash
# Using Docker scan
docker scan myapp:latest

# Using Trivy
trivy image myapp:latest

# Using Snyk
snyk container test myapp:latest
```

### 6. Minimize Privileged Operations

```dockerfile
# ❌ Avoid if possible
RUN chmod 777 /app

# ✅ Use specific permissions
RUN chmod 755 /app && \
    chown appuser:appuser /app
```

### 7. Use COPY Instead of ADD

```dockerfile
# ❌ ADD has hidden features (URL fetching, tar extraction)
ADD . .

# ✅ COPY is explicit and preferred
COPY . .

# ✅ Only use ADD for tar extraction
ADD app.tar.gz /app/
```

### 8. Health Checks

```dockerfile
# HTTP health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# TCP health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD nc -z localhost 8000 || exit 1

# Custom script
HEALTHCHECK --interval=30s --timeout=3s \
  CMD /app/healthcheck.sh || exit 1
```

### 9. Read-Only Root Filesystem

```dockerfile
# In Dockerfile, specify writable volumes
VOLUME /tmp
VOLUME /var/log

# Run with read-only filesystem
# docker run --read-only -v /tmp -v /var/log myapp
```

---

## Performance Optimization

### 1. Use Build Cache Effectively

```dockerfile
# ✅ Dependencies first (cached)
COPY package.json package-lock.json ./
RUN npm ci

# ✅ Source code last (changes often)
COPY . .
RUN npm run build
```

### 2. Parallel Builds with BuildKit

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Or use docker buildx
docker buildx build --platform linux/amd64,linux/arm64 -t myapp .
```

```dockerfile
# Use parallel RUN commands
FROM node:20 AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
# BuildKit can parallelize these
RUN npm run build:client & npm run build:server
```

### 3. Cache Mount (BuildKit)

```dockerfile
# Syntax directive
# syntax=docker/dockerfile:1.4

FROM python:3.11-slim

WORKDIR /app

# Use cache mount for pip packages
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
```

### 4. Optimize Python Applications

```dockerfile
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Precompile Python files
RUN python -m compileall .

CMD ["python", "app.py"]
```

### 5. Optimize Node.js Applications

```dockerfile
FROM node:20-alpine

ENV NODE_ENV=production \
    NPM_CONFIG_LOGLEVEL=error

WORKDIR /app

# Use npm ci for faster, deterministic installs
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

COPY . .

CMD ["node", "--max-old-space-size=512", "server.js"]
```

---

## Development Workflow

### 1. Development vs Production Images

```dockerfile
# Base stage
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./

# Development stage
FROM base AS development
ENV NODE_ENV=development
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]

# Production stage
FROM base AS production
ENV NODE_ENV=production
RUN npm ci --only=production
COPY . .
CMD ["npm", "start"]
```

Build and run:
```bash
# Development
docker build --target development -t myapp:dev .
docker run -v $(pwd):/app myapp:dev

# Production
docker build --target production -t myapp:prod .
docker run myapp:prod
```

### 2. Hot Reload in Development

```dockerfile
FROM node:20-alpine
WORKDIR /app

COPY package*.json ./
RUN npm install

# Install nodemon for hot reload
RUN npm install -g nodemon

EXPOSE 3000

CMD ["nodemon", "--watch", ".", "--ext", "js,json", "server.js"]
```

Run with volume mount:
```bash
docker run -v $(pwd):/app -p 3000:3000 myapp:dev
```

### 3. Build Arguments for Flexibility

```dockerfile
ARG NODE_VERSION=20
FROM node:${NODE_VERSION}-alpine

ARG BUILD_DATE
ARG VERSION
ARG GIT_COMMIT

LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.revision=$GIT_COMMIT

WORKDIR /app

COPY . .

CMD ["npm", "start"]
```

Build with arguments:
```bash
docker build \
  --build-arg VERSION=1.2.3 \
  --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  --build-arg GIT_COMMIT=$(git rev-parse HEAD) \
  -t myapp:1.2.3 .
```

---

## Production Deployment

### 1. Production-Ready Python Application

```dockerfile
# Build stage
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.11-slim

WORKDIR /app

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copy virtual environment
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application
COPY . .

# Create non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8000/health')" || exit 1

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "--timeout", "60", "app:app"]
```

### 2. Production-Ready Node.js Application

```dockerfile
# Dependencies stage
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Builder stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN yarn build

# Runner stage
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nodeuser

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

USER nodeuser

EXPOSE 3000

ENV PORT=3000

HEALTHCHECK --interval=30s --timeout=3s \
  CMD node healthcheck.js || exit 1

CMD ["node", "dist/server.js"]
```

### 3. Graceful Shutdown

```dockerfile
# Add tini for proper signal handling
FROM node:20-alpine

RUN apk add --no-cache tini

WORKDIR /app

COPY . .

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

CMD ["node", "server.js"]
```

In your application:
```javascript
// server.js
process.on('SIGTERM', () => {
  console.log('SIGTERM received, closing server...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});
```

---

## Troubleshooting

### 1. Debug Build Issues

```bash
# Build with no cache
docker build --no-cache -t myapp .

# Build with progress output
docker build --progress=plain -t myapp .

# Build specific stage
docker build --target builder -t myapp:builder .

# Inspect intermediate layers
docker run -it <layer-id> /bin/sh
```

### 2. Debug Running Container

```bash
# View logs
docker logs -f myapp

# Execute shell
docker exec -it myapp /bin/sh

# Inspect container
docker inspect myapp

# View processes
docker top myapp

# View resource usage
docker stats myapp
```

### 3. Common Issues

#### Issue: "COPY failed: no such file or directory"
**Solution:** Check your `.dockerignore` file

#### Issue: Large image size
**Solution:**
- Use multi-stage builds
- Use smaller base images
- Remove cache and temporary files
- Use .dockerignore

#### Issue: Build cache not working
**Solution:**
- Order Dockerfile instructions properly
- Copy dependency files before source code
- Avoid `COPY . .` early in Dockerfile

#### Issue: Permission denied
**Solution:**
```dockerfile
RUN chown -R appuser:appuser /app
USER appuser
```

### 4. Image Analysis

```bash
# Inspect image layers
docker history myapp:latest

# Analyze image with dive
dive myapp:latest

# Export image
docker save myapp:latest -o myapp.tar

# Import image
docker load -i myapp.tar
```

---

## Checklist for Production

- [ ] Use specific base image tags (not `latest`)
- [ ] Implement multi-stage builds
- [ ] Run as non-root user
- [ ] Add health checks
- [ ] Use .dockerignore file
- [ ] Remove package manager cache
- [ ] Set proper environment variables
- [ ] Implement graceful shutdown
- [ ] Add metadata labels
- [ ] Scan for vulnerabilities
- [ ] Test with limited resources
- [ ] Document build arguments
- [ ] Version your images
- [ ] Keep images under 500MB (when possible)
- [ ] Log to stdout/stderr

---

## Additional Resources

- [Docker Official Documentation](https://docs.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [BuildKit Documentation](https://docs.docker.com/build/buildkit/)
