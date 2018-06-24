build:
	sudo ./init.sh

cleanup:
	sudo docker stop http-service || true
	sudo docker rm http-service || true
	sudo docker network rm http-br || true
