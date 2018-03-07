build:
	sudo ./init.sh

cleanup:
	sudo docker stop peer1 peer2 peer3 || true
	sudo docker rm peer1 peer2 peer3 || true
	sudo docker network rm simple-hb-br || true

1:
	sudo docker run -it --name peer1 \
	  --network simple-hb-br \
	  --ip "10.0.4.21" \
	  --publish 8080:8080 \
	  simple-hb

2:
	sudo docker run -it --name peer2 \
	  --network simple-hb-br \
	  --ip "10.0.4.21" \
	  --publish 8080:8080 \
	  simple-hb

3:
	sudo docker run -it --name peer3 \
	  --network simple-hb-br \
	  --ip "10.0.4.21" \
	  --publish 8080:8080 \
	  simple-hb
