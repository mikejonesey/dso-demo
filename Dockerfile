FROM maven:3.8.7-openjdk-18-slim as build

WORKDIR /app
COPY .  .
RUN mvn package -DskipTests

FROM openjdk:18-alpine AS run
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar /run/demo.jar
ARG USER=devops
ENV HOME /home/$USER
RUN adduser --disabled-password $USER && \
  chown $USER:$USER /run/demo.jar
USER $USER
EXPOSE 8080
CMD java  -jar /run/demo.jar
