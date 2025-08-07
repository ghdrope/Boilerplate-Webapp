#
# ----- Stage 1: Build the frontend assets -----
#
FROM node:22-alpine AS builder

# Set working directory inside the container
WORKDIR /app

# Copy package files first to leverage Docker cache for dependencies
COPY frontend/package.json frontend/yarn.lock ./

# Install dependencies exactly as specified in yarn.lock for reproducible builds
RUN yarn install --frozen-lockfile

# Copy the rest of the frontend source code
COPY frontend/ .

# Build the frontend app using Vite
RUN yarn build



#
# ----- Stage 2: Serve the built app using Nginx -----
#
FROM nginx:1.28-alpine

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy custom Nginx configuration (assume it's in project root)
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Copy the built frontend assets
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80 to serve HTTP traffic
EXPOSE 80

# Start nginx in the foreground (so the container doesn't exit)
CMD ["nginx", "-g", "daemon off;"]