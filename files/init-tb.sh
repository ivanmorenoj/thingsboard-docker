#!/bin/bash
# init script

set -e
CONF_FOLDER="/usr/share/thingsboard/conf"
jarfile=/usr/share/thingsboard/bin/thingsboard.jar
configfile=thingsboard.conf
firstlaunch=${DATA_FOLDER}/.firstlaunch

source "${CONF_FOLDER}/${configfile}"

# export DB environment variables
export SPRING_DATASOURCE_URL=jdbc:postgresql://${PG_HOST}:${PG_PORT}/thingsboard
export SPRING_DATASOURCE_USERNAME=${PG_USER}
export SPRING_DATASOURCE_PASSWORD=${PG_PASS}

until nmap $PG_HOST -p $PG_PORT | grep "$PG_PORT/tcp open"
do
  echo "Waiting for postgres db to start..."
  sleep 2
done

if [ ! -f ${firstlaunch} ]; then
  echo "Starting ThingsBoard installation ..."
  java -cp ${jarfile} $JAVA_OPTS -Dloader.main=org.thingsboard.server.ThingsboardInstallApplication \
                  -Dinstall.load_demo=${LOAD_DEMO} \
                  -Dspring.jpa.hibernate.ddl-auto=none \
                  -Dinstall.upgrade=false \
                  -Dlogging.config=/usr/share/thingsboard/bin/install/logback.xml \
                  org.springframework.boot.loader.PropertiesLauncher
  touch ${firstlaunch}
fi

echo "Starting ThingsBoard ..."
java -cp ${jarfile} $JAVA_OPTS -Dloader.main=org.thingsboard.server.ThingsboardServerApplication \
                    -Dspring.jpa.hibernate.ddl-auto=none \
                    -Dlogging.config=${CONF_FOLDER}/logback.xml \
                    org.springframework.boot.loader.PropertiesLauncher