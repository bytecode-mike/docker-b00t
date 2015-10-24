FROM java:8
VOLUME /tmp

ENV SYSTODO_HOME="/opt/systoto"
ENV SYSTODO_JAR=$SYSTODO_HOME"/"systodo-web-0.0.1-SNAPSHOT.jar

RUN mkdir -p $SYSTODO_HOME"/lib" 
ADD systodo-web-0.0.1-SNAPSHOT.jar $SYSTODO_JAR

ENTRYPOINT java -Djava.security.egd=file:/dev/./urandom $JAVA_OPTS -jar $SYSTODO_JAR
