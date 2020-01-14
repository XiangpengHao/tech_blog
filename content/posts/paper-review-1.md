---
title: "Paper Review: Database System Architectures"
date: 2020-01-13T22:18:18-08:00
draft: false 
---

In a nutshell: data is migrating from disk to memory, and how can we design new system to fit this trend.

### The End of an Architectural Era (It’s Time for a Complete Rewrite) (2007)

In this paper, the authors tried to convince that the old one-fit-all database architecture is no longer fit for the emerging hardwares, 
database researchers should start with new empty sheets of paper and focus on tomorrow's requirements.

The authors provided several interesting points:

##### Single threaded system

Traditional database systems leverages multi-threading to utilize the CPU cycles while one thread is blocked by IO.
This blocking no longer exits in main memory database systems, the authors then argues that future main memory database systems will be single threaded.
From the point of 2020, we know modern systems still uses multi-threading, not to hide IO latency, but rather to hide memory latency. 

First of all, we know a single CPU core cannot saturate the memory bandwidth, thus it's always beneficial to run multiple 
concurrent queries.

The question is, what if memory latency is so low that a single thread can fullfil the whole memory bandwidth, in this case, do we need multi-threading?
We probably don't in most cases. Multi-threading though can be helpful to achieve task fairness and priority scheduling.

This, however, is not a practical assumption: even though the memory capacity and bandwidth dramatically increased over the years, the memory latency remains in a stable state.
Thus in the foreseeable future, we will still be cursed by the multi-threading models. 


#### The overheads
Apart from the insightful ideas of future database system architecture, the paper also mentioned the major overheads of transitional database systems, in a nutshell: locking and logging.

It's quite interesting because the locks are used to guarantee concurrency consistency, and the logs are used to enforce crash consistency.
These two challenges are still top questions in 2020!

In 2020, we typically run the database system with far more threads, how to achieve high throughput under high contention thus becomes the new big topic.
With the advent of persistent memory, people hope it can help  logging in a very straightforward way.
It turns out to be more problematic and more chaotic, the reason is we still have a long way to go to achieve safe and fast byte-addressable persistent memory operations. 


### HyPer: A Hybrid OLTP&OLAP Main Memory Database System Based on Virtual Memory Snapshots (2011)

This is a very interesting paper, the biggest question ringing in my ears is: what can I learn from the fancy technique.

The authors tried to incorporate the OLAP and OLTP with a very simple trick: the `fork()` system call in unix systems.
The key idea is to `fork()` the current OLTP process whenever a OLAP query comes in.
This simple tech leverages the copy-on-update optimization in the modern operating system.  
The `fork()` system call promised isolated virtual memory address, basically a snapshot of current system, without duplicating all the user memory.

This paper is interesting because it shows how high-level systems can craft their design to fit the design of low-level systems.
In this case, it's not possible to achieve the same goal without tremendous overhead in the user space.
This paper, however, observed that the OLAP isolation can be easily achieved by re-purposing the `fork()` system call.

It teaches us two important lessons:

**Re-purposing** a well-established system can be extremely profitable if there is a proper usage.

This conclusion is not new, it's actually a wide spread principle in cancer research, where medical researchers trying to deal with cancers by utilizing the side-effects of common medicines (because developing new drugs can be pricy and time-consuming).
For computer scientists (system research), the scenario can be: how can we combine the existing SIMD instructions to achieve new goals?
Or how can we use a the old kernel feature (even bugs) to solve a particular problem?

**System co-design** is important. 
Re-purposing is not a solution, it's rather a smart temporary workaround, it can not solve every problem.
Thus to minimize the design overhead, if possible, we need to co-design our higher and lower systems. 

System co-design has two aspects: a) tasks should be performed in appropriate abstractions, 
e.g. a small feature in hardware can address thousands issues in software, 
b) low level design should aware of high level applications, 
e.g. a database-specific operating system knows isolation is a huge demand, thus it has `isolation()` system call.
