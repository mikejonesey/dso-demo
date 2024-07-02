FROM maven:3.8.7-openjdk-18-slim as build

WORKDIR /app
COPY .  .
RUN mvn package -DskipTests

FROM openjdk:18-alpine AS run

# Sec Patch
RUN apk update && apk upgrade libtasn1 zlib

# Copy from build
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar /run/demo.jar

# Add Runtime User
ARG USER=devops
ENV HOME /home/$USER
RUN adduser --disabled-password $USER && \
  chown $USER:$USER /run/demo.jar

# Healthcheck
RUN apk add curl
HEALTHCHECK --interval=30s --timeout=10s --retries=2 --start-period=20s \
  CMD curl -f http://localhost:8080/ || exit 1

# Runtime Settings
USER $USER
EXPOSE 8080
CMD java  -jar /run/demo.jar
