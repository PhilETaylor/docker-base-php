docker pull php:8.2.4-alpine3.16

docker buildx rm base-php

echo "STARTING BUILDING ON AN M1 MAC"

# RUN THIS ON Intel Mac
# docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 1234:1234 bobrik/socat TCP-LISTEN:1234,fork UNIX-CONNECT:/var/run/docker.sock

docker buildx create --name base-php --use --platform linux/arm64
docker buildx create --name base-php --append tcp://159.65.95.228:1234 --platform linux/amd64

docker buildx build . --platform linux/amd64,linux/arm64 --no-cache --push --tag philetaylor/base-php:latest
