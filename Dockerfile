FROM openjdk:8-jre-slim-buster

ENV THINGS_BOARD_VERSION 3.0.1

ENV PG_HOST=postgresql \
    PG_PORT=5432 \ 
    PG_USER=postgres \
    PG_PASS=postgres

ENV LOAD_DEMO=true \
    LOW_RAM_USAGE=false \
    DATA_FOLDER=/data \
    HTTP_BIND_PORT=9090 \
    DATABASE_TS_TYPE=sql \
    DATABASE_ENTITIES_TYPE=sql\
    SPRING_JPA_DATABASE_PLATFORM=org.hibernate.dialect.PostgreSQLDialect \
    SPRING_DRIVER_CLASS_NAME=org.postgresql.Driver 

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nmap curl && \
    apt-get clean && \
    apt-get autoremove -y && \
<<<<<<< HEAD
    echo ${THINGS_BOARD_VERSION} > /etc/tb-release && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -L https://github.com/thingsboard/thingsboard/releases/download/v${THINGS_BOARD_VERSION}/thingsboard-${THINGS_BOARD_VERSION}.deb -o /tmp/thingsboard.deb && \
=======
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -L https://github.com/thingsboard/thingsboard/releases/download/v2.4.3/thingsboard-2.4.3.deb -o /tmp/thingsboard.deb && \
>>>>>>> b1b4da6... cheate dockefile for slim-buster base image
    dpkg --force-all -i /tmp/thingsboard.deb && rm -rf /tmp/*

COPY files/logback.xml files/thingsboard.conf /usr/share/thingsboard/conf/
COPY files/init-tb.sh /usr/bin/

RUN chmod a+x /usr/bin/init-tb.sh

EXPOSE 9090
EXPOSE 1883
EXPOSE 5683/udp

VOLUME ["/data"]

CMD ["/usr/bin/init-tb.sh"]
