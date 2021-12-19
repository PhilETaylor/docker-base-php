docker pull php:alpine3.15

docker buildx rm base-php

# M1
if [[ `uname -m` == 'arm64' ]]; then

  echo "STARTING BUILDING ON AN M1 MAC"

  # RUN THIS ON Intel Mac
  # docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 1234:1234 bobrik/socat TCP-LISTEN:1234,fork UNIX-CONNECT:/var/run/docker.sock

  #  docker buildx create --name base-php --use --platform linux/arm64
  #  docker buildx create --name base-php --append tcp://192.168.1.70:1234 --platform linux/amd64

  #  docker buildx build --platform linux/arm64 --no-cache --push --tag philetaylor/base-php:latest
  docker buildx build . --platform linux/amd64,linux/arm64 --no-cache --push --tag philetaylor/base-php:latest
fi

# Intel
if [[ `uname -m` != 'arm64' ]]; then

  echo "STARTING BUILDING ON AN INTEL MAC"

  # RUN THIS ON M1 Mac
  # docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 1234:1234 bobrik/socat TCP-LISTEN:1234,fork UNIX-CONNECT:/var/run/docker.sock

  docker buildx create --name base-php --use --platform linux/amd64
  docker buildx create --name base-php --append tcp://192.168.1.227:1234 --platform linux/arm64

  docker buildx build . --platform linux/amd64,linux/arm64 --no-cache --push --tag philetaylor/base-php:latest
fi

docker pull philetaylor/base-php:latest

echo "BUILDING COMPLETE"

# 458Mb 363MB
