# ThingsBoard in docker

![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ivanmorenoj/thingsboard?style=plastic)
![Docker Stars](https://img.shields.io/docker/stars/ivanmorenoj/thingsboard?style=plastic)
![Docker Pulls](https://img.shields.io/docker/pulls/ivanmorenoj/thingsboard?style=plastic)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/ivanmorenoj/thingsboard?style=plastic)
![Docker Image Version (latest semver)](https://img.shields.io/docker/v/ivanmorenoj/thingsboard?sort=semver&style=plastic)

This ThingsBoard in docker container based in [this repo](https://hub.docker.com/r/thingsboard/tb-postgres). \
This version doesn't contain postgres database inside container, so you can add your own database or use one from docker compose file.

## Usage from docker compose

Clone git repo
```sh
git clone https://github.com/ivanmorenoj/thingsboard-docker.git

cd thingsboard-docker
```

Init ThingsBoard with docker-compose
```sh
docker-compose up -d 
```

See logs
```sh
docker-compose logs
```

## Deploy ThingsBoard with docker swarm
```sh
docker stack deploy -c swarm-deploy.yml tb
```

## Default username / password

After executing this command you can open http://{yor-host-ip}:9090 in your browser. \
You should see ThingsBoard login page. Use the following default credentials:

- **Systen Administrator:** sysadmin@thingsboard.org / sysadmin
- **Tenant Administrator:** tenant@thingsboard.org / tenant
- **Customer User:** customer@thingsboard.org / customer

You can always change passwords for each account in account profile page.
