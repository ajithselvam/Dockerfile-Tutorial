# Stage 1: Build
FROM nginx:alpine AS builder

WORKDIR /usr/share/nginx/html

COPY index.html .

# Stage 2: Production
FROM nginx:alpine

COPY --from=builder /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
