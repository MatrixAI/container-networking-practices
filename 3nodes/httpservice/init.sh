cleanup() {
  docker rm http-server 2> /dev/null
  docker network rm http-br 2> /dev/null
}

cleanup

docker build -t http-service .

docker network create \
  -d bridge \
  --subnet=10.0.5.0/24 \
  http-br

sudo docker run -it --name http-server \
	  --network http-br \
	  --ip "10.0.5.2" \
	  --publish 8000:8000 \
	  http-service
