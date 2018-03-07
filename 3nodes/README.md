# 3nodes
This directory contains two projects:
- [**LANChat Containers**](#LANChat-containers): creates three docker containers running LANChat.
- [**Simple Heartbeat**](#Simple HB): runs three docker containers with simple heartbeat communication (tunable heartbeat).

## LANChat-containers
### Prerequisites
- A Linux machine
- Python3.6+
- docker
- git

### Running for the first time

1. Run `make` in the `LANChat-Containers` directory to configure and download
all necessary files and configure container network.
1. Then, to Instantiate each container, run the following commands on three
**different** terminals: (Or alternatively use the `make [1 | 2 | 3]` command)

```bash
# Container 1
docker run -it --name peer1 \
  --network lanchat-br \
  --ip "10.0.3.21" \
  --publish 8080:8080 \
  lanchat
```
```bash
# Container 2
docker run -it --name peer2 \
  --network lanchat-br \
  --ip "10.0.3.22" \
  --publish 8081:8080 \
  lanchat
```
```bash
# Container 3
docker run -it --name peer3 \
  --network lanchat-br \
  --ip "10.0.3.23" \
  --publish 8082:8080 \
  lanchat
```

### Clean up
Run `make cleanup`

## Simple HB
I've written a python script for 3 peers to talk and receive random messages of arbitrary size via TCP connection. packet sizes can be changed by altering the `HEARTBEAT_SIZE` global variable in `main.py`.

### Prerequisites
- A linux machine
- Python3.6
- docker

### Running simple hb
1. Run `make` in the `simple-hb` directory to configure and download
all necessary files, configurations and fire up 3 containers.

*Note: Different to `LANChat-Containers` this program doesn't require GUI, so it will simply run in the background after the first step.*

### Clean up
Run `make cleanup`
