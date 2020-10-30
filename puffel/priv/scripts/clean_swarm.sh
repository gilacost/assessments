#!/bin/bash

docker swarm leave --force
docker-compose build
docker swarm init
docker service create --name registry --publish published=5000,target=5000 registry:2
docker-compose push
docker stack deploy --compose-file docker-compose.yml puffel
mix ecto.create
