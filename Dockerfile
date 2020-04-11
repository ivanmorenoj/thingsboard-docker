FROM ubuntu:18.04

ENV PG_HOST=postgresql
ENV PG_PORT=5432
ENV PG_USER=postgres
ENV PG_PASS=postgres

ENV DATA_FOLDER=/data
ENV HTTP_BIND_PORT=9090
ENV DATABASE_TS_TYPE=sql
ENV DATABASE_ENTITIES_TYPE=sql
ENV SPRING_JPA_DATABASE_PLATFORM=org.hibernate.dialect.PostgreSQLDialect
ENV SPRING_DRIVER_CLASS_NAME=org.postgresql.Driver

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-8-jdk iputils-ping nmap curl && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    update-alternatives --auto java

COPY files/logback.xml files/thingsboard.conf files/start-tb.sh files/upgrade-tb.sh files/install-tb.sh /tmp/

RUN chmod a+x /tmp/*.sh \
    && mv /tmp/start-tb.sh /usr/bin \
    && mv /tmp/upgrade-tb.sh /usr/bin \
    && mv /tmp/install-tb.sh /usr/bin

RUN curl -L https://github.com/thingsboard/thingsboard/releases/download/v2.4.3/thingsboard-2.4.3.deb -o /tmp/thingsboard.deb && \
    dpkg -i /tmp/thingsboard.deb

RUN mv /tmp/logback.xml /usr/share/thingsboard/conf \
    && mv /tmp/thingsboard.conf /usr/share/thingsboard/conf \
    && rm -rf /tmp/*


EXPOSE 9090
EXPOSE 1883
EXPOSE 5683/udp

VOLUME ["/data"]

CMD ["/usr/bin/start-tb.sh"]
