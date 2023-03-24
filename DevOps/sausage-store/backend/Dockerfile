# build
FROM maven:3.8.2-openjdk-16-slim as builder
ARG VERSION=${VERSION}
WORKDIR /usr/src/app
COPY ./src ./src
COPY *.xml ./
COPY ./tls/*.pem ./
RUN curl https://storage.yandexcloud.net/cloud-certs/CA.pem -o YandexInternalRootCA.crt \
    && mvn package -Dversion.application=${VERSION}

# release
FROM openjdk:16-jdk-alpine
ARG VERSION=${VERSION}
WORKDIR /app
COPY --from=builder /usr/src/app/YandexInternalRootCA.crt .
COPY --from=builder /usr/src/app/pdmitrievCA.pem .
RUN keytool -importcert -file YandexInternalRootCA.crt \
    -alias yandex -cacerts -storepass changeit -noprompt \
    && keytool -importcert -file pdmitrievCA.pem \
    -alias pdmitrievCA -cacerts -storepass changeit -noprompt \
    && rm -rf YandexInternalRootCA.crt \
    && rm -rf pdmitrievCA.pem \
    && addgroup --system jaruser \
    && adduser -S -s /bin/false -G jaruser jaruser -D -H \
    && chown -R jaruser:jaruser /app \
    && apk add --no-cache dumb-init==1.2.5-r0
COPY --chown=jaruser:jaruser \
     --from=builder /usr/src/app/target/sausage-store-${VERSION}.jar ./sausage-store.jar
RUN apk add --update curl
EXPOSE 8080
USER jaruser
ENTRYPOINT ["dumb-init", "java", "-jar", "-Dmyserver.bindPort=8080", "./sausage-store.jar"]