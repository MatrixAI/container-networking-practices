build:
	sudo ./init.sh

cleanup:
	sudo docker stop peer1 peer2 peer3 || true
	sudo docker rm peer1 peer2 peer3 || true
	sudo docker network rm simple-hb-br || true
