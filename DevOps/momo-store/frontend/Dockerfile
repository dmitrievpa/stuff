#build
FROM node:16.13.2 as builder
WORKDIR /usr/src/app
COPY . .
RUN npm install \
    && npm run build
#release
FROM nginx:1.23.3-alpine
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html
EXPOSE 80