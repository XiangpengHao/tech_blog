---
title: "Cost of NUMA vs Context Switch, Part 1"
date: 2019-07-01T19:26:19-07:00
draft: false
---

### Background

Socket: aka Node, CPU chip. Modern high performance server can install up to four CPU chips, aka four socket machine.

Memory topology: each socket can have up to six channels (have six memory slots), so on a four socket machine, the maximum number of memory chip installed is `4 * 6 = 24`. 
Process accessing memory installed on its own socket is called `local memory access`, accessing memory installed on other sockets is called `remote memory access`. 

NUMA (non uniform memory access): cross socket memory access.

NUMA effect: `local memory` access is about **50% faster**[^1] than `remote memory` access. 


### The Problem

NUMA effect limited the scalability of a high performance system.
The number of cpus that can be installed on a single motherboard is bounded by the bandwidth of memory bus. 

### Cost of NUMA vs Context Switch

The easiest solution is to re-schedule the current process so that the majority of the memory access stay local. But it's not as sweet as it sounds like, as most memory access are scattered around all four sockets[^2], and **re-scheduling has a cost**.

To the best of my knowledge, most current in-memory indexes are not NUMA aware, because it's really hard to keep a balance between *cost of context switch* and *cost of NUMA*. 
And NUMA aware memory access typically need huge amount of re-design on the structure level of the index, and most wide used tricks don't show positive result here.

The topic of this post is not about NUMA aware design, instead just want to demonstrate the cost of NUMA effect and the cost of context switch.


### Method

Programming in NUMA sockets, I take the following factors into consideration:

1. Cache miss, did we really issue a memory load, or just used the cached values. So to simulate the real-world workload, I evicted the whole last level cache between tests.

2. Cost of re-scheduling. How costly it is for on-fly context switch. Cost of rescheduling is the most important criteria to achieve beneficial NUMA optimization, as it's a trade-off between context switch and remote memory access.

3. CPU pipelines, with very regular workload, modern CPU is capable of maintaining a quite low branch prediction miss rate, thus can hide the memory access latency due to predictable pre-fetch. While in the real-world cases, the workload tends to be very irregular thus less predictable. Trivial tests might not be enough to demonstrate the NUMA-effect.

My workload is defined as follows:

1. Each bucket stores 2-20 cache lines of uint64_t values.

2. The buckets are chained together, just as linked list.

3. The workload is to calculate the sum of 100-10000 buckets.

4. Before each test, all related cache lines are evicted by `clflush`[^3].

There're three categories of access pattern:

1. Baseline: 100% local memory access

2. NUMA: 100% remote memory access

3. Re-scheduled: this process will land on a remote socket, then we force it to reschedule to current local socket, then 100% local memory access.

The number of cache line in a bucket controls the irregularity of the workload, in other words, less cache line in a bucket (thus more bucket jump needed) leads to high irregularity of the workload.

On the other hand, the number of total bucket controls the total workload, it's used to measure the cost against context switching.  


Result reserved for next post.


[^1]: Basic Performance Measurements of the Intel Optane DC Persistent Memory Module

[^2]: The GNU allocator will by default allocate local memory, but memory access might happen in any socket.

[^3]: `clflush` is not the best way to evict cache line, but all other ways don't seem to work :(

