#!/bin/bash
# init script

set -e

# Custom config files
if [ -z "$CONF_FOLDER" ]; then
  CONF_FOLDER="/usr/share/thingsboard/conf"
fi
if [ -z "$CONFIG_FILE" ]; then
  CONFIG_FILE=thingsboard.conf
fi

jarfile=/usr/share/thingsboard/bin/thingsboard.jar
firstlaunch=${DATA_FOLDER}/.firstlaunch
versionFile=${DATA_FOLDER}/.tb-currentVersion
containerVersion=$(cat /etc/tb-release)

source "${CONF_FOLDER}/${CONFIG_FILE}"

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
if [ "$POSTGRES_SSL" = "enabled" ]; then
  mkdir -p /etc/psql-ssl-keys/
  openssl pkcs8 -topk8 -inform PEM -outform DER -in ${PG_SSL_KEY_FILE} -out /etc/psql-ssl-keys/client-key.pk8 -nocrypt
  cp ${PG_SSL_CERT_FILE} /etc/psql-ssl-keys/client-cert.pem
  cp ${PG_SSL_ROOTCERT_FILE} /etc/psql-ssl-keys/server-ca.pem
  chmod -R a+r /etc/psql-ssl-keys/
  
  export SPRING_DATASOURCE_URL="jdbc:postgresql://${PG_HOST}:${PG_PORT}/${PG_DATABASE}?sslmode=${PG_SSL_MODE}&sslrootcert=/etc/psql-ssl-keys/server-ca.pem&sslcert=/etc/psql-ssl-keys/client-cert.pem&sslkey=/etc/psql-ssl-keys/client-key.pk8"
else
  export SPRING_DATASOURCE_URL="jdbc:postgresql://${PG_HOST}:${PG_PORT}/${PG_DATABASE}"
fi
export SPRING_DATASOURCE_USERNAME=${PG_USER}
export SPRING_DATASOURCE_PASSWORD=${PG_PASS}

# print db config
echo "================================= Being DB config ===================================="
echo "Database URL: $SPRING_DATASOURCE_URL"
echo "Database user: $SPRING_DATASOURCE_USERNAME"
echo "================================= End DB config   ===================================="

# Wait for postgres database
until nmap -Pn $PG_HOST -p $PG_PORT | grep "$PG_PORT/tcp open"; do
  echo "Waiting for postgres db to start..."
  sleep 2
done

# Install thingsboard for first time
if [ ! -f ${firstlaunch} ]; then
  echo "Starting ThingsBoard installation ..."
  java -cp ${jarfile} $JAVA_OPTS -Dloader.main=org.thingsboard.server.ThingsboardInstallApplication \
                  -Dinstall.load_demo=${LOAD_DEMO} \
                  -Dspring.jpa.hibernate.ddl-auto=none \
                  -Dinstall.upgrade=false \
		  -Dlogging.config=/usr/share/thingsboard/bin/install/logback.xml \
                  org.springframework.boot.loader.PropertiesLauncher
  touch ${firstlaunch}
  cat /etc/tb-release > ${versionFile}
fi

# Get the current version
actualVersion=$(cat ${versionFile})
 
# Upgrade from last version to actual version
if [ "$ENABLE_UPGRADE" = "true" ] && [ ! "$(printf '%s\n' "$actualVersion" "$containerVersion" | sort -V | head -n1)" = "$containerVersion" ]; then 
  echo "The current version is ${actualVersion}"
  echo "Container version is ${containerVersion}"
  echo "Upgrading to ${containerVersion}..."

  java -cp ${jarfile} $JAVA_OPTS -Dloader.main=org.thingsboard.server.ThingsboardInstallApplication \
                -Dspring.jpa.hibernate.ddl-auto=none \
                -Dinstall.upgrade=true \
                -Dinstall.upgrade.from_version=${actualVersion} \
		-Dlogging.config=/usr/share/thingsboard/bin/install/logback.xml \
                org.springframework.boot.loader.PropertiesLauncher

  echo ${containerVersion} > ${versionFile}
fi

# Init thingsboard
echo "Starting ThingsBoard ..."
java -cp ${jarfile} $JAVA_OPTS -Dloader.main=org.thingsboard.server.ThingsboardServerApplication \
                    -Dspring.jpa.hibernate.ddl-auto=none \
                    -Dlogging.config=${CONF_FOLDER}/logback.xml \
                    org.springframework.boot.loader.PropertiesLauncher
