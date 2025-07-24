#
# ----- Stage 1: Build -----
#
FROM node:22-alpine AS builder

WORKDIR /frontend

# Copy package.json and yarn.lock to install dependencies
COPY frontend/package.json frontend/yarn.lock ./

RUN yarn install --frozen-lockfile

# Copy the rest of the frontend source code
COPY frontend/ .

# Build the Vite app
RUN yarn build



#
# ----- Stage 2: Serve with nginx -----
#
FROM nginx:alpine

# Copy static build files from builder stage to nginx html directory
COPY --from=builder /frontend/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]