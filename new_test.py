import zmq
from time import time
from multiprocessing import Process

class ZMQTest(object):
    num_sent = 0
    num_received = 0
    test_size = 1000000
    def __init__(self, filename):
        self.filename = filename
        self.start_send()
        self.start_receive()

    def chase_tail(self):
        while True:
            with open(self.filename, 'r') as handle:
                for line in handle:
                    yield line

    def start_send(self):
        self.start_proc = Process(target=self.send_loop, args=())
        self.start_proc.start()

    def start_receive(self):
        self.receive_proc = Process(target=self.receive_loop, args=())
        self.receive_proc.start()

    def send_loop(self):
        from datetime import datetime
        start = datetime.now()
        self.msg_source = self.chase_tail()
        self.context = zmq.Context()
        self.init_send()
        while self.num_sent < self.test_size:
            self.send()
        print datetime.now() - start

    def receive_loop(self):
        self.context = zmq.Context()
        self.init_receive()
        while self.num_received < self.test_size:
            self.receive()

class SimpleTest(ZMQTest):
    def init_send(self):
        self.socket = self.context.socket(self.send_type)
        self.socket.bind("tcp://*:5555")

    def init_receive(self):
        self.socket = self.context.socket(self.receive_type)
        self.socket.connect("tcp://*:5555")

class PipeLineTest(SimpleTest):
    receive_type = zmq.PULL
    send_type = zmq.PUSH

    def send(self):
        self.socket.send(self.msg_source.next())
        self.num_sent += 1

    def receive(self):
        self.socket.recv()
        self.num_received += 1

class ReqRepTest(SimpleTest):
    receive_type = zmq.REQ
    send_type = zmq.REP

    def send(self):
        self.socket.recv()
        self.socket.send(self.msg_source.next())
        self.num_sent += 1

    def receive(self):
        self.socket.send('plz')
        self.socket.recv()
        self.num_received += 1

ReqRepTest('/var/log/syslog')


