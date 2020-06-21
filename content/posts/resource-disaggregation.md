---
title: "Resource Disaggregation"
date: 2020-06-20T12:20:42-07:00
draft: false 
---

This post is less of a paper review but more of some random thoughts about resources disaggregation.

The two papers are "Understanding the Effect of Data Center Resource Disaggregation on Production DBMSs" and
"Rethinking Data Management Systems for Disaggregated Data Centers".
The paper are easy to follow and educational, I learned a lot from them.


### What is resource disaggregation?
Hardware resources (CPU, main memory, GPU, SSD, HDD) are split into independently managed pools that are connected by a high-performance network fabric.

### The motivation behind resource disaggregation?
Cloud computing drives this trend because they have the following business need:
1. To upgrade and expand each resources independently.
If the workload changes to require additional CPUs, the operator can deploy new compute nodes without needing to upgrade memory nodes or worry about the compatibility.
2. To promote efficient resource utilization and prevents fragmentation.
For example, if a customer requests an unusual hardware configuration -- such as 7 cores, 100 GB RAM, 3 GPUs -- 
the operator can allocate those resources without committing an over-provisioned machine.  

### What are the benefits?
1. Independent expansion. 
2. Independent failure. 
I'm a bit concerned with this claim. It's intuitive and relatively easy to recover a storage node or even memory node, 
but I don't believe it's possible to recover from a CPU node failure.
For example, what if the CPU node was holding a lock before it fails, the only safe way (on top of my mind) is to abort all other CPU nodes.
3. Independent allocation.

### New challenges?
1. Now we have two -- instead of one -- memory sets, the local memory of a computing node and the remote memory from memory pool. 
This new layer of indirection is new to all existing DBMSs.
2. The memory is significantly slower, as they are on network.
To make things worse, this is not a distributed system where our solution is to minimize remote communication.
In the disaggregated environment, accessing the remote memory is a necessity rather than an optimization.
In other words, our mental mode is not to think about minimizing remote memory access, but to consider how to manage our working set more smartly. 
3. How to handle the independent fails? 

### Hows the performance if we do nothing?
The paper benchmarked MonetDB (in-memory) and PostgreSQL (out-of-core) on LegOS (the state-of-the-art resource disaggregation operating system) with TPC-H benchmark.
From the paper description, we can infer the LegOS is more of a research prototype rather than a highly-optimized production operation system. 
1. MonetDB is about 1.7x slower with 4GB memory on compute nodes
2. PostgreSQL is about 2x slower on hot execution while similar performance on cold execution.

The performance bottleneck is apparently the remote memory access via network.

### Are the benefits outweigh the costs?
Under the context of DBMS, we only consider three different resources: CPU, main memory and SSD.
The benefits comes from the fact that these components are physically independent while the cost mainly comes from remote main memory access.

So the question is that are we paying too much for **memory disaggregation**?
I have no doubt that storage/GPU disaggregation can have negligible performance overhead if we try hard, 
but I'm conservative about memory disaggregation -- not only about its current performance, 
but also doubt that we can get around with this overhead.    


### An end-to-end view
New architecture changes try to be transparent to existing applications (so that people can adopt it with minimal efforts), 
but sometimes they shouldn't, especially for performance critical applications -- 
where platform agnostic is just unrealistic claim. 

So what to keep in mind when designing cloud native applications?
1. Storage: we can assume storage is replicated.
> In Aurora, durable redo record application happens at the storage tier, continuously, asynchronously, and distributed across the fleet. Any read request for a data page may require some redo records to be applied if the page is not current. As a result, the process of crash recovery is spread across all normal foreground processing. Nothing is required at database startup.
2. Memory is slow and hierarchical: local DRAM is smaller but faster than remote DRAM.
It sounds like NUMA but not exactly.



### A view on the evolution
I'm not convinced that memory disaggregation will be widely adopted anytime soon.
The motivation of memory disaggregation is just not as strong as other components: 
1. It's common to have hundreds GBs of memory in a bare-metal server. 
Cloud operators can easily configure the resource in software.
2. Memory is cheap, especially the new persistent memory.

