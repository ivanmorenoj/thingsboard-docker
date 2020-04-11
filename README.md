# Thingsboard in docker

This ThingsBoard in docker container based in [this repo](https://hub.docker.com/r/thingsboard/tb-postgres).
This version doesn't contain postgres database inside container, so you can add your own database or use one from docker compose file.

## Usage from docker compose

Clone git repo
```sh
git clone https://github.com/ivan28823/thingsboard-docker.git

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


