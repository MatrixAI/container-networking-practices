###
### Instantiate 3 docker containers wth Simple-hb running
###

cleanup() {
  docker stop peer1 peer2 peer3
  docker rm peer1 peer2 peer3
  docker network rm simple-hb-br 2> /dev/null
}

if [ ! -f "./Dockerfile" ]
then
  cat << EOF > Dockerfile
# Pull base image.
FROM python:3

ADD . /home/vagrant/

WORKDIR /home/vagrant/

CMD ./main.py

# Expose ports.
EXPOSE 8080
EOF
fi

echo Dockerfile written

cleanup

docker build -t simple-hb .

docker network create \
  -d bridge \
  --subnet=10.0.4.0/24 \
  simple-hb-br
