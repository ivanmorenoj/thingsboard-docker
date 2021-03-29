FROM docker.io/ubuntu:20.04

ENV THINGS_BOARD_VERSION 3.2.2

ENV TB_DOWNLOAD_URL="https://github.com/thingsboard/thingsboard/releases/download/v3.2.2/thingsboard-3.2.2.deb"

ENV PG_HOST=postgresql \
    PG_PORT=5432 \ 
    PG_USER=postgres \
    PG_PASS=postgres \
    PG_DATABASE=thingsboard \
    POSTGRES_SSL=disabled

ENV ENABLE_UPGRADE=false \
    LOAD_DEMO=true \
    LOW_RAM_USAGE=false \
    DATA_FOLDER=/data \
    HTTP_BIND_PORT=9090 \
    DATABASE_TS_TYPE=sql \
    DATABASE_ENTITIES_TYPE=sql\
    SPRING_JPA_DATABASE_PLATFORM=org.hibernate.dialect.PostgreSQLDialect \
    SPRING_DRIVER_CLASS_NAME=org.postgresql.Driver 

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-11-jdk nmap curl && \
    update-alternatives --auto java && \
    curl -L ${TB_DOWNLOAD_URL} -o /tmp/thingsboard.deb && \
    dpkg -i /tmp/thingsboard.deb && rm -rf /tmp/* && \
    apt-get autoremove -y && \
    echo ${THINGS_BOARD_VERSION} > /etc/tb-release && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY files/logback.xml files/thingsboard.conf /usr/share/thingsboard/conf/
COPY files/init-tb.sh /usr/bin/

RUN chmod a+x /usr/bin/init-tb.sh

EXPOSE 9090
EXPOSE 1883
EXPOSE 5683/udp

VOLUME ["/data"]

CMD ["/usr/bin/init-tb.sh"]
