# 1. Tahap Build
FROM maven:3.8.4-openjdk-17 AS build

WORKDIR /app

COPY . .

RUN mvn clean package -DskipTests

# 2. Tahap Run
FROM tomcat:9.0-jdk17-openjdk

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080