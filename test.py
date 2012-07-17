import zmq
from time import time
from multiprocessing import Process

def ventilator(batch_size, test_size):
    """task ventilator function"""

    """set up a zeromq context"""
    context = zmq.Context()

    """create a push socket for sending tasks to workers"""
    send_sock = context.socket(zmq.PUSH)
    send_sock.bind("tcp://*:5555")

    """create a pull socket for receiving acks from the sink"""
    recv_sock = context.socket(zmq.PULL)
    recv_sock.bind("tcp://*:5557")

    """initiate counter for tasks sent"""
    current_batch_count = 0

    """start the message loop"""
    for x in range(test_size):

        """send until we reach our batch limit"""
        while current_batch_count < batch_size:
            send_sock.send("task")
            current_batch_count += 1

        """reset the batch count"""
        current_batch_count = 0

        """wait for an acknowledgement and block while waiting -
           note this could be more sophisticated and provide
           support for other message types from the sink,
           but keeping it simple for this example"""
        recv_sock.recv()


def worker():
    """task worker function"""

    """set up a zeromq context"""
    context = zmq.Context()

    """create a pull socket for receiving tasks from the ventilator"""
    recv_socket = context.socket(zmq.PULL)
    recv_socket.connect("tcp://*:5555")

    """create a push socket for sending results to the sink"""
    send_socket = context.socket(zmq.PUSH)
    send_socket.connect("tcp://*:5556")

    """receive tasks and send results"""
    while True:
        recv_socket.recv()
        send_socket.send("result")

def sink(batch_size, test_size):
    """task sink function"""

    """set up a zmq context"""
    context = zmq.Context()

    """create a pull socket for receiving results from the workers"""
    recv_socket = context.socket(zmq.PULL)
    recv_socket.bind("tcp://*:5556")

    """create a push socket for sending acknowledgements to the ventilator"""
    send_socket = context.socket(zmq.PUSH)
    send_socket.connect("tcp://*:5557")

    result_count = 0
    batch_start_time = time()
    test_start_time = batch_start_time

    for x in range(test_size):
        """receive a result and increment the count"""
        recv_socket.recv()
        result_count += 1

        """acknowledge that we've completed a batch"""
        if result_count == batch_size:
            send_socket.send("ACK")
            result_count = 0
            batch_start_time = time()

    duration = time() - test_start_time
    tps = test_size / duration
    print "messages per second: %s" % (tps)



if __name__ == '__main__':
    num_workers = 4
    batch_size = 100
    test_size = 1000000

    workers = {}
    ventilator = Process(target=ventilator, args=(batch_size, test_size,))
    sink = Process(target=sink, args=(batch_size, test_size,))

    sink.start()

    for x in range(num_workers):
        workers[x] = Process(target=worker, args=())
        workers[x].start()

    ventilator.start()
