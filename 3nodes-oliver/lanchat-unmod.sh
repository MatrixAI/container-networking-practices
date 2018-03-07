###
### Instantiate 3 docker containers wth LANChat running
###



cat << EOF > Dockerfile
# Pull base image.
FROM python:3

ADD ./LANChat /home/vagrant/LANChat

WORKDIR /home/vagrant/LANChat

CMD ./main.py

# Expose ports.
EXPOSE 8080
EOF

if [ ! -d "./LANChat" ]
then
  git clone https://github.com/mokuki082/LANChat.git
  mkdir LANChat/config
  touch LANChat/config/host.json /LANChat/config/peers.csv
  cat << EOF > ./LANChat/config/host.json
{
  "color": null,
  "ip": "0.0.0.0",
  "port": 8080,
  "username": "peer"
}
EOF
  echo host configuration written;
  cat << EOF > ./LANChat/config/peers.csv
10.0.3.21:8080
10.0.3.22:8080
10.0.3.23:8080
EOF
  echo host configuration written
fi


cleanup() {
  docker stop peer1 peer2 peer3
  docker rm peer1 peer2 peer3
  docker network rm lanchat-br 2> /dev/null
}

cleanup

docker build -t lanchat .

docker network create \
  -d bridge \
  --subnet=10.0.3.0/24 \
  lanchat-br

docker run -it --name peer1 \
  --network lanchat-br \
  --ip "10.0.3.21" \
  --publish 8080:8080 \
  lanchat

# # Run this in another terminal
docker run -it --name peer2 \
  --network lanchat-br \
  --ip "10.0.3.22" \
  --publish 8081:8080 \
  lanchat
#
# # Run this in another terminal
# docker run -it --name peer3 \
#   --network lanchat-br \
#   --ip "10.0.3.23" \
#   --publish 8082:8080 \
#   lanchat
