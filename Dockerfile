# 1. Tahap Build
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# 2. Tahap Run (Gunakan versi penuh agar lebih kompatibel)
FROM tomcat:9.0-jdk17-openjdk
RUN rm -rf /usr/local/tomcat/webapps/*
# Mengambil file .war dan menamainya ROOT.war agar langsung akses di domain utama
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]