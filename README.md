# CH/OTP Test Task

This project is my solution to the "CH/OTP Test Task" problem defined in http://f.nn.lv/od/5c/8y/CH_OTP_Test_Task(1).pdf.

## Building project

To build executables just run `stack build`. This will create binaries for your operating system.

## How to execute the program

### 1. Initialize worker nodes 

You can initilize worker node using script `run-worker.sh` with following arguments:

```
./run-worker.sh [--host HOST] [--port PORT]
```

Run this for every node in the cluster.

### 2. Run master node to trigger calculations

You can run master node using script `run-master.sh` with following arguments:

```
./run-master.sh [--host HOST] [--port PORT] [--sendFor SEND_FOR] [--waitFor WAIT_FOR]
```

Run this on a single node. 

Once the master nodes terminates, worker nodes will also terminate printing the final result on the console.


## Approach

I will try to approach the problem by implementing a total ordered queue of events as described in [Time, Clocks, and the Ordering of Events in a Distributed System by Leslie Lamport](https://amturing.acm.org/p558-lamport.pdf) using logical clocks for partial ordering and `ProcessId` for totall ordering of processes.
