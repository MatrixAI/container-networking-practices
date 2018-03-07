#!/usr/bin/env python3

import socket
import threading
import time
import datetime

HOSTNAME = "0.0.0.0"
PORT = 8081
PEERS = [("127.0.0.1", 8080), ("127.0.0.1", 8081), ("127.0.0.1", 8082)]
HEARTBEAT_SIZE = 10 # in bytes


class Client():
    def __init__(self):
        pass

    def unicast(self, peer, message):
        if not isinstance(message, bytes):
            raise ValueError('Message should be in bytes')
        t = threading.Thread(target=self.__send_worker,
                         args=(peer, message),
                         daemon=True)
        t.start()
        return t

    def broadcast(self, message):
        """Broadcast a message to all peers."""
        if not isinstance(message, bytes):
            raise ValueError("Message should be in bytes")
        t = []
        for p in PEERS:
            t.append(self.unicast(p, message))
        for i in t:
            i.join()


    def __send_worker(self, peer, message):
        try:
            # Using TCP socket, change to RAW or DGRAM if you like
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
                sock.connect(peer)
                sock.sendall(message)
                sock.close()
                print('{} Sent heartbeat to {}'.format(str(datetime.datetime.now()), peer))
        except ConnectionRefusedError:
            pass
        except TimeoutError:
            pass
        except ValueError:
            pass
        except BrokenPipeError:
            pass
        except OSError:
            pass

class Server():
    def __init__(self):
        self.socket = socket.socket()
        try:
            self.socket.bind((HOSTNAME, PORT))
        except OSError:
            print('Error: port taken')
            exit(1)

    def serve(self):
        # Create a thread pool
        nthreads = 4
        # threads format: [[thread_object, client_socket, client_ip]]
        self.threads = []
        for i in range(nthreads):
            self.threads.append([threading.Thread(target=self.handle,
                                                  args=(i,),
                                                  daemon=True
                                                  ),
                                None, None]
                                )
            self.threads[i][0].start()
        # Start listening for connections
        self.socket.listen()
        # Give a task to a thread in the thread pool
        while True:
            try:
                client, addr = self.socket.accept()
            except ConnectionAbortedError:
                break
            found_thread = False
            # Select a thread to give the task to
            while not found_thread:
                for thread in self.threads:
                    if not thread[1]:
                        thread[1] = client
                        thread[2] = addr
                        found_thread = True
                        break
                time.sleep(0.01)
            time.sleep(0.05)

    def handle(self, tid):
        while True:
            if self.threads[tid][1]:
                client, addr = self.threads[tid][1:]
                ip = addr[0]
                data = b''
                data_chunk = client.recv(HEARTBEAT_SIZE)
                print("{} Received heartbeat from {}".format(str(datetime.datetime.now()), addr))
                client.close()
                self.threads[tid][1] = None
                self.threads[tid][2] = None
            time.sleep(0.5)

if __name__ == "__main__":
    client = Client()
    server = Server()
    print('{} starting server'.format(str(datetime.datetime.now())))
    threading.Thread(target=server.serve, daemon=True).start()
    print("{} Server started".format(str(datetime.datetime.now())))
    with open('/dev/urandom', 'rb') as f:
        print("{} Start sending heartbeat".format(str(datetime.datetime.now())))
        while True:
            client.broadcast(f.read(HEARTBEAT_SIZE))
            time.sleep(1)
