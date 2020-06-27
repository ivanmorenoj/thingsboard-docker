#!/bin/bash
# init script

set -e
CONF_FOLDER="/usr/share/thingsboard/conf"
jarfile=/usr/share/thingsboard/bin/thingsboard.jar
configfile=thingsboard.conf
firstlaunch=${DATA_FOLDER}/.firstlaunch
versionFile=${DATA_FOLDER}/.tb-currentVersion
containerVersion=$(cat /etc/tb-release)

source "${CONF_FOLDER}/${configfile}"

# set low ram usage in java opts
if [ "$LOW_RAM_USAGE" = "true" ]; then
  echo "Set low ram usage for thingsboard"
  export JAVA_OPTS="$JAVA_OPTS -Xms256M -Xmx256M"
fi

# Check if password is in file
if [ ! -z "$PG_PASS_FILE" ]; then
  echo "Set password from file: $PG_PASS_FILE"
  PG_PASS=$(cat ${PG_PASS_FILE})
fi

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
                  -Dlogging.config=/${CONF_FOLDER}/logback.xml \
                  org.springframework.boot.loader.PropertiesLauncher
  touch ${firstlaunch}
  cat /etc/tb-release > ${versionFile}
fi

actualVersion=$(cat ${versionFile})

if [ "$(printf '%s\n' "$actualVersion" "$containerVersion" | sort -V | head -n1)" = "$containerVersion" ]; then 
  echo "You are running the container version..."
else 
  echo "The current version is ${actualVersion}"
  echo "Container version is ${containerVersion}"
  echo "Upgrading to ${containerVersion}..."

  java -cp ${jarfile} $JAVA_OPTS -Dloader.main=org.thingsboard.server.ThingsboardInstallApplication \
                -Dspring.jpa.hibernate.ddl-auto=none \
                -Dinstall.upgrade=true \
                -Dinstall.upgrade.from_version=${actualVersion} \
                -Dlogging.config=${CONF_FOLDER}/logback.xml \
                org.springframework.boot.loader.PropertiesLauncher

  echo ${containerVersion} > ${versionFile}
fi

echo "Starting ThingsBoard ..."
java -cp ${jarfile} $JAVA_OPTS -Dloader.main=org.thingsboard.server.ThingsboardServerApplication \
                    -Dspring.jpa.hibernate.ddl-auto=none \
                    -Dlogging.config=${CONF_FOLDER}/logback.xml \
                    org.springframework.boot.loader.PropertiesLauncher
