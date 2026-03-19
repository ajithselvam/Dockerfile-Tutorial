
to remove docker container if it exists
docker rm -f $(docker ps -aq -f name=my-container) 2>/dev/null || true

to remove docker image if it exists
docker rmi -f $(docker images -q my-image) 2>/dev/null || true
