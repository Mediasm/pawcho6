# Specify the syntax for the frontend Buildkit
# syntax=docker/dockerfile:1

# Stage 1: Frontend Buildkit
FROM docker:20.10.16 AS buildkit-frontend

# Install SSH client
RUN apk add --no-cache openssh-client git

# Configure SSH and add GitHub host key to known hosts
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Clone the pawcho6 repository using SSH key
RUN --mount=type=ssh,id=lab6_ssh git clone git@github.com:mediasm/pawcho6.git /app

# Stage 2: Build Node.js application
FROM node:alpine AS builder

# Copy the contents of the pawcho6 repository from the buildkit-frontend stage
COPY --from=buildkit-frontend /app /app

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json files
COPY package*.json ./

# Install application dependencies
RUN npm install

# Copy the application code
COPY index.js ./
COPY src ./src

# Stage 3: Create a minimal image with Nginx
FROM nginx:alpine

# Build argument for version
ARG VERSION=1.0.0

# Use the build argument to set an environment variable
ENV VERSION=${VERSION}

# Install Node.js
RUN apk add --update nodejs

# Copy the application code from the builder stage
COPY --from=builder /app /app

# Remove the default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy the custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/

# Expose the port on which the application runs
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s \
  CMD curl -f http://localhost || exit 1

# Start Nginx and the Node.js application
CMD ["sh", "-c", "nginx & node /app/index.js"]