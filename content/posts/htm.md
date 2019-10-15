---
title: "The case of Hardware Transactional Memory: performance and usage"
date: 2019-10-10T19:11:27-07:00
draft: true
---

## Features [^1]

1. The L1 cache serves as a transactional buffer, i.e. max size of a transaction is the size of L1 cache.

2. The cache coherency protocol is used to detect transactional conflicts.

3. There's no guarantee that a transaction will ever succeed.

4. A CPU cannot exercise CLWB, CLFLUSHOPT, non-cacheable stores and SFENCE within a transaction.[^2]

## Cache associativity might cause transaction abort

Consider a CPU with 8-way L1 cache associativity, i.e., each cache set has 8 entries,
a transaction tries to access 9 memory positions, where all these memory are mapped to the same set.
Since it's impossible to have all these 9 cache lines in the L1 cache at the same time, the transaction will definitely abort, and restart the transaction will not help.

In practice, the bit 7-12 of memory addresses are used to determine the cache set, it's unlikely to have multiple cache lines to be in the same cache set. The figure below, however, shows the abort rate because of cache associativity.

![](/img/htm-size.png)

## Other issues might cause transaction abort

**TLB miss**: more memory access

**Interruption**: long running transaction might suffer from more hardware interruptions, thus cause higher abort rate. (because of more memory access or the nature of interruption? to be confirmed.)

**False conflict**: Item A and B are in the same cache line, even though they are modified in different transactions, it will cause a conflict.


## Compatible with Persistent Memory?

No, HTM operates on cache level, there's no guarantee on all aspects.

(Why persistent memory cause so many problems? 
From my understanding, the CPU cache is designed to be transparent to applications, while persistent memory breaks this convention. 
With persistent memory, cache line management will have correctness impact on the application, but we lack the tools and knowledge to make it correct.)

What if we have battery-backed CPU cache? I don't know, my guess is still no.



[^1]: Exploiting Hardware Transactional Memory in Main-Memory Databases


[^2]: Hardware Transactional Persistent Memory