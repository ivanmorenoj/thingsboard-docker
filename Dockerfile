FROM openjdk:8-jre-slim-buster

ENV PG_HOST=postgresql
ENV PG_PORT=5432
ENV PG_USER=postgres
ENV PG_PASS=postgres

ENV LOAD_DEMO=true
ENV DATA_FOLDER=/data
ENV HTTP_BIND_PORT=9090
ENV DATABASE_TS_TYPE=sql
ENV DATABASE_ENTITIES_TYPE=sql
ENV SPRING_JPA_DATABASE_PLATFORM=org.hibernate.dialect.PostgreSQLDialect
ENV SPRING_DRIVER_CLASS_NAME=org.postgresql.Driver

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nmap curl && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -L https://github.com/thingsboard/thingsboard/releases/download/v2.4.3/thingsboard-2.4.3.deb -o /tmp/thingsboard.deb && \
    dpkg --force-all -i /tmp/thingsboard.deb && rm -rf /tmp/*

COPY files/logback.xml files/thingsboard.conf /usr/share/thingsboard/conf/
COPY files/init-tb.sh /usr/bin/

RUN chmod a+x /usr/bin/init-tb.sh

EXPOSE 9090
EXPOSE 1883
EXPOSE 5683/udp

VOLUME ["/data"]

CMD ["/usr/bin/init-tb.sh"]
