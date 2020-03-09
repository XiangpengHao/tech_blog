---
title: "Paper Review: Network DB"
date: 2020-03-08T11:59:26-07:00
draft: false 
---

This week's papers talk about distributed database systems.
So what's the difference between distributed database systems and other distributed systems?

In the case of distributed system, the main challenge is the limited bandwidth and sub-optimal TCP/IP protocol.
Most of the research work was spent on reducing the inter-data center network and increase the intra-nodes traffic.
This kind of work is very much like the magnified NUMA issues, the difference though, is the difference between WAN speed and LAN speed is much bigger than that of local socket and remote socket.

Back to the first question, database systems often require a stricter consistency requirement and typically has higher concurrency. 

### SLOG: serializable, low-latency, geo-replicated transactions
This paper tries to achieve the following goals at the same time: (1) strict serializability (2)
low latency writes (3) high transactional throughput.
I personally don't like how they describe these goals, as these goals are too general to deliver any useful ideas.
Just like all other cross-region distributed systems, the main idea is to reduce coordination.
While data center coordination should be generally avoided, inter-data center communication should be more aggressively reduced than intra-data center communication.
The opportunity comes from the observation that some data has higher geo-affinity than other data, for example, all the data related to a single user is very likely to be accessed/changed from its home region.

Although the data is geo-replicated, it has home replica and remote replicas. 
A remote replica can be migrated to home replica for better performance.

### Strong consistency is not hard to get: Two-Phase Locking and Two-Phase Commit on Thousands of Cores
This paper evaluates the two-phase locking and two-phase commit on modern distributed systems.
The authors implemented these algorithms using the new RDMA (remote direct memory access) technologies and find that even with just text-book implementation,
these algorithms perform quite good performance. 
This new finding is refreshed the assumption that 2PL and 2PC are not viable due to high communication overhead.
Apart from these conclusions, the paper also argued that in future distributed systems the network card will have higher computation power and offload more compute from the CPU nodes.

Why do we call it a distributed system when all the computing nodes are connected by high bandwidth, low latency and reliable network?
In modern data center, the network latency can be as low as 1-2us (note that DRAM latency is about 0.1-0.3 us).
In other words, this kind of latency/bandwidth is more like a slower type of DRAM.
The network, however, can do more things than DRAM can.
Because in-memory processing is not commercialized yet while programmable switch is ubiquities both in the industry and academia.
So to embrace the next generation of distributed system, the question on our side is, how do we offload the computing to the network card, and what kind of workload should be offload?
 






