---
title: "Paper Review: Persistent Memory"
date: 2020-02-20T11:54:11-08:00
draft: false 
---

Persistent memory is different from other new hardware, because it breaks some old assumptions and introduces more complex concepts.
Other new hardware, like GPU, can transparently replace some part of computation pipeline,
thus researchers mainly focus on how to exploit the computation power of new devices.
Persistent memory, however, fundamentally changed how the programming itself should look like:
it requires applications to take control of the CPU cache behavior (while it's designed to be transparent),
it asks for a new level of memory safety, and etc.

Both the industry and academia need a long time to figure out how the current systems should co-exist with persistent memory. 

The first paper focus on how to uncover the maximum potential of persistent memory, this paper falls into the traditional category of optimizing for new hardware.
The second paper discuss more about the impact of persistent memory: how to handle persistency, concurrency and memory safety. 

### Rethinking Database Algorithms for Phase Change Memory

This paper talks about PCM, which I believe is not the technology behind Intel Optane.

The paper try to deal with asymmetric read/write performance of PCM under the context of database system.
The core idea is simple: write operation is slow and costly, future system should try their best to avoid write operations.

The novelty of this paper comes from "the first system of its kind".

A possible improvement of this paper is to enhance the evaluation part: since this is pure single-thread simulation and all the evaluation operations turn to be deterministic. 
In this way, we can simply perform a static analysis or even just mathematical operation count to get all the numbers.
For example, to study the impact of sorted node vs unsorted node, one can just calculate the expected read write operations instead of using the simulation, because every operation is deterministic. One advantage of static analysis is we can easily obtain more insights by altering various parameters.


### BzTree: A High-Performance Latch-free Range Index for Non-Volatile Memory

This paper mainly try to demonstrate the use of PMwCAS.
The main contribution of PMwCAS, safety and programmability, however is largely under estimated by the community.
The reasons are two-fold: people assume safety to be easy and second nature, 
but most of persistent memory paper are either incorrect (e.g. misunderstanding of how system work) or ignore some critical components (safe memory allocation/reclaim). 
On the other hand, programmability is very hard to measure and the general academia tends to undervalue the impact of programmability.  

Nevertheless, BzTree is not the best usage of PMwCAS.
People might think BzTree is slow because PMwCAS is slow (because it's difficult to spot the BzTree's inherit design inefficiencies). 






