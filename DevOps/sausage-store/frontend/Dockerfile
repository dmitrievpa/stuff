#Build
FROM node:16.13.2 as builder
WORKDIR /usr/src/app
COPY . .
RUN npm install \
    && npm run build

FROM nginxproxy/nginx-proxy:latest
WORKDIR /app
# COPY nginx.tmpl /app/
# COPY nginx.conf /etc/nginx/
COPY --from=builder /usr/src/app/dist/frontend/* /usr/share/nginx/html/
RUN mkdir -p /data/nginx/cache/