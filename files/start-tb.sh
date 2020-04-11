#!/bin/bash
#
# Copyright © 2016-2020 The Thingsboard Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


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
  sleep 1
done

if [ ! -f ${firstlaunch} ]; then
    install-tb.sh --loadDemo
    touch ${firstlaunch}
fi

echo "Starting ThingsBoard ..."

java -cp ${jarfile} $JAVA_OPTS -Dloader.main=org.thingsboard.server.ThingsboardServerApplication \
                    -Dspring.jpa.hibernate.ddl-auto=none \
                    -Dlogging.config=${CONF_FOLDER}/logback.xml \
                    org.springframework.boot.loader.PropertiesLauncher
