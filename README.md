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

I approach the problem by implementing a total ordered queue of events as described in [Time, Clocks, and the Ordering of Events in a Distributed System by Leslie Lamport](https://amturing.acm.org/p558-lamport.pdf).

The general algorithm is described as follows:

1. master initialize work for workers and pauses for timeout provided by `sendFor`
2. workers generate internal events, send them to other workers and store events comming as messages from other workers
3. logical clock is implemented in order to keep partial ordering of events
4. upon incoming `Stop` message from the master,  workers stop generating internal events, while still acceping external messages
5. master pauses for timeout provided by `waitFor`
6. upon incoming `Results` message from the master, workers sort events according to the => relation (which gives total ordering by combining partial ordering from logical clocks and total ordering of process)
7. having events sorted, each worker prints out the result
8. workers send `Done` message to the master
9. once all `Done` messages are received, master terminates all worker nodes and then stops its execution

## Possible improvements

### 1. Handling of process failure

As described by Lamport 


> However, the resulting algorithm requires the active participation of all the processes. A process must know all the commands issued by other processes, so that the failure of a single process will make it impossible for any other process to execute State Machine commands, thereby halting the system. 


Thus the algorithm should work in non-perfect network but will halt if one the process dies definitely. 

Lamport point to his other paper [The Implementation of Reliable Distributed Multiprocess Systems"](https://lamport.azurewebsites.net/pubs/implementation.pdf) which is an introduction to the consensus protocols (which seemd out of scope of this test)

### 2. Process as (sort of) partial functions

Implementation uses more "low-level" API of `distributed-process`, instead of `Typed Channels`. During the implementation process this even led to one error, that could be spotted during compilation time (rather then runtime) if `typed channels` were used.
