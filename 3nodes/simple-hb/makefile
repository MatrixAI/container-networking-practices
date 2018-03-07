build:
	sudo ./init.sh

cleanup:
	sudo docker stop peer1 peer2 peer3 || true
	sudo docker rm peer1 peer2 peer3 || true
	sudo docker network rm lanchat-br || true

1:
	docker run -it --name peer1 \
	  --network lanchat-br \
	  --ip "10.0.3.21" \
	  --publish 8080:8080 \
	  simple-hb

2:
	docker run -it --name peer2 \
	  --network lanchat-br \
	  --ip "10.0.3.21" \
	  --publish 8080:8080 \
	  simple-hb

3:
	docker run -it --name peer3 \
	  --network lanchat-br \
	  --ip "10.0.3.21" \
	  --publish 8080:8080 \
	  simple-hb
