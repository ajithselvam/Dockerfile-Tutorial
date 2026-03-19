docker rm -f $(docker ps -aq -f name=my-container) 2>/dev/null || true
