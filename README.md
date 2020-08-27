# Docker - BounCA

This container is used to build BounCA.

Version alpha

## Available Architectures
- amd64
- arm64 (aarch64)
- armv7 (arm)

## Try it out
```
# Create dedicated docker network
docker network create net-bounca

# Start PSQL server
docker run --name postgres --network=net-bounca --network-alias=postgres -e POSTGRES_PASSWORD=bounca -d postgres:alpine

# Start BounCA
docker run --name bounca --network=net-bounca -e DB_PWD=bounca -d noxinmortus/docker-bounca
```

## Sources
- https://github.com/repleo/bounca/
- https://github.com/repleo/docker-bounca
- https://github.com/repleo/docker-compose-bounca
- https://www.bounca.org/getting_started.html#deploy-docker
