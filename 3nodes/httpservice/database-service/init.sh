cleanup() {
  docker rm database-server01 2> /dev/null
}

cleanup

docker build -t database-server .

sudo docker run -it --name http-server01 \
	  --network http-br \
	  --ip "10.0.5.3" \
	  --publish 8000:8000 \
	  database-server
