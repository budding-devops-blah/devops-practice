FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG JAR_FILE=target/helloworld-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} helloworld-0.0.1-SNAPSHOT.jar
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -Dserver.port=8080 -Djava.security.egd=file:/dev/./urandom -jar /helloworld-0.0.1-SNAPSHOT.jar"]
