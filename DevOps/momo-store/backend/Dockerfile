#build
FROM golang:alpine as build
ARG VERSION=${VERSION}
WORKDIR /usr/src/app
COPY go.mod go.sum ./
RUN go mod download && go mod verify
COPY . .
RUN mkdir -p /usr/bin/app && go build -v -o /usr/bin/app ./...
#release
FROM alpine
WORKDIR /app
COPY --from=build /usr/bin/app/api /app/api
RUN addgroup --system appuser \
    && adduser -S -s /bin/false -G appuser appuser -D -H \
    && chown -R appuser:appuser /app
EXPOSE 8081
USER appuser
ENTRYPOINT ["./api"]