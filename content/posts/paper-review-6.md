---
title: "Paper Review: Accelerators"
date: 2020-03-01T18:17:29-08:00
draft: false 
---

Accelerators, especially the FPGAs, have gained increasingly more popularity both in the industry and academia.
The major reason behind this popularity stems from the end of Moore's law, where people can not expect the CPU performance to grow exponentially to solve existing performance issues.
In other words, we need to take actions to improve the system performance, otherwise it will likely to remain unchanged for the next few years.

FPGAs are sound and well-established co-processor in improving the performance of overall system. 
FPGAs, however, are not the answer to all performance problems. Rather, they're just some high performance co-processors that can speed up some computation **at some cost**. 
It's **a research problem** in determining in which role the FPGAs can maximize their potentials, 
and most importantly, what is the computing pattern for future high-performance systems? 

The first paper talks about near-data processing.
The main motivation is to reduce data movement between the clients and the servers.
FPGAs act as embedded yet feature-complete computation power on edge devices.
The second paper tries to integrate the FPGAs into an existing computation intensive data processing pipeline. 
In contrast to the first paper where the authors try to use FPGAs on data-intensive system, 
in the second paper the authors uses FPGAs to address computation-intensive problems.
Combining these two paper is more interesting than looking them separately.


### Caribou: Intelligent Distributed Storage

The most thought provoking word in this paper is **near-data processing**.
For the past few decades our computation model has been centered around a central processing unit, a.k.a CPU.

We were trained to think in this way: to compute any thing, we need to move data from storage to memory, 
then to the CPU cache; after the computation, we flush the CPU cache back to the memory and eventually persist the data on the storage.
We were fine with this paradigm because our data were relatively small, 
our data-caching policy were extremely effective and our parallel computation power was limited.
But the recent trends force us out of the comfort zone: the number of data grows exponentially, 
the number of threads grows exponentially, while the single thread performance is believed to be stable.

Moving data across the indirection hierarchy has been one of the major performance bottlenecks.
So people think about ways to address this problem, and using FPGA is one of the potential answers.

This paper presents Caribou, a FPGA-implemented key value store.
The concept of near-data processing comes from FPGA processing on the embedded DRAM.

(more on the presentation)



### Lowering the Latency of Data Processing Pipelines Through FPGA based Hardware Acceleration
The authors try to replace a CPU-based machine learning model to a FGPA-based model.
The machine learning inference is known to be floating-number intensive and is largely limited by the CPU clock frequency.
A FPGA chip can definitely help under such workload, not only does it have better throughput, but also be an order of more power efficient.

The cost of FPGA in terms of throughput, however, is data movement (which is exactly the second paper trying to address).
Data interaction between the PCIe (and even the network) can be costly compared to that with the main memory.
Given what we have discussed, the workload need to be sufficiently heavy in order to accommodate the data movement cost.
Machine learning inferences is a good fit, while other workloads (e.g. graph processing or single index query) might not be.

The majority parts of the paper is boring because it looks like just a new system that utilized the FPGA, but there are several sparkling points:

1. Why not GPUs? When talking about accelerator, the GPUs are probably the most widely researched and deployed ones.
This paper has a tiny section that answers this question, and there's a particularly important sentence: "we are not aware of any significance on inference over decision tree ensembles on GPUs due to the irregular nature of the computations." 
The answer is simple: GPU is good at handling regular data while that particular machine learning model happens to be dominated by irregular memory access.
2. What are the data movement cost? The authors installed the FPGAs on PCIe channels and fast network.
The evaluations (Figure 9.c) shows the CPU-FPGA bandwidth indeed limits the scalability of the whole system.
Nevertheless, the benefits of FPGS acceleration is so significant that the data movement in the target scenario is negligible.


