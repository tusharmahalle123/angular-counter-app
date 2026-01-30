# Stage 1: Build the Angular app using Node.js
FROM node:18-alpine as build

# Create a non-root user #RUN useradd -m node

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Set environment variable for OpenSSL legacy provider
ENV NODE_OPTIONS=--openssl-legacy-provider

WORKDIR /usr/src/app

# Copy package.json and package-lock.json first to leverage caching
COPY package.json* ./

# Install project dependencies
RUN npm install

# Copy the rest of the application files
COPY . .

# Build the Angular app
RUN npm run build

# Stage 2: Serve the Angular app with Nginx
FROM nginx:alpine

# Set correct ownership and permissions for the nginx user to read the files
RUN chown -R nginx:nginx /usr/share/nginx/html
RUN chmod -R 755 /usr/share/nginx/html

# Set the user to nginx
USER nginx

RUN rm /usr/share/nginx/html/*

# Copy the built app from the previous stage to Nginx
COPY --from=build /usr/src/app/dist/ /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
