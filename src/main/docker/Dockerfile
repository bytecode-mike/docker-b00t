FROM java:8
VOLUME /tmp

ENV SYSTODO_HOME="/opt/systoto"
# the @@jarfile@@ is a palceholder for the jar name, it will be solecd during deploy,
# if you do not see it then the replacement happen
ENV SYSTODO_JAR=$SYSTODO_HOME"/"@@jarfile@@

RUN mkdir -p $SYSTODO_HOME"/lib" 
ADD @@jarfile@@ $SYSTODO_JAR

ENTRYPOINT java -Djava.security.egd=file:/dev/./urandom $JAVA_OPTS -jar $SYSTODO_JAR
