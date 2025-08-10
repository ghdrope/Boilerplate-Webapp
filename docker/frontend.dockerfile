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

# Create non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Create nginx cache directory with proper ownership
RUN mkdir -p /var/cache/nginx/client_temp \
    && chown -R appuser:appgroup /var/cache/nginx

# Create /run directory and give ownership to appuser
RUN mkdir -p /run \
    && chown appuser:appgroup /run

# Change ownership of the static files to the non-root user
RUN chown -R appuser:appgroup /usr/share/nginx/html

# Optional: Change Nginx listen port to 8080 to avoid requiring root privileges
RUN sed -i 's/listen 80;/listen 8080;/' /etc/nginx/nginx.conf
EXPOSE 8080

# Run Nginx as non-root user
USER appuser

# Start nginx in the foreground (so the container doesn't exit)
CMD ["nginx", "-g", "daemon off;"]