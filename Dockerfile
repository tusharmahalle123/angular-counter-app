# ---------- Stage 1: Build Angular ----------
FROM node:18-alpine AS build

ENV NODE_OPTIONS=--openssl-legacy-provider
WORKDIR /usr/src/app

# Install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy source and build
COPY . .
RUN npm run build

# ---------- Stage 2: Nginx Runtime ----------
FROM nginx:alpine

# Create runtime directories
RUN mkdir -p /var/cache/nginx /run \
 && chown -R nginx:nginx /var/cache/nginx /run /usr/share/nginx \
 && chmod -R 755 /var/cache/nginx /run /usr/share/nginx

# Remove default html
RUN rm -rf /usr/share/nginx/html/*

# ⚠️ Copy Angular build CONTENTS to root (not folder)
COPY --from=build /usr/src/app/dist/counter-app/. /usr/share/nginx/html/

# Fix permissions
RUN chown -R nginx:nginx /usr/share/nginx/html \
 && chmod -R 755 /usr/share/nginx/html

# Switch to non-root user
USER nginx

# Expose HTTP port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
