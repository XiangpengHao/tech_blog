---
title: "Paper Review: IR and Compiler"
date: 2020-05-18T15:58:24-07:00
draft: false 
---

Compilers are hot in this area, in this post I'll review three representative papers that using compilers/IR to simplify and accelerate the system.
In this review, I'll focus on the story, i.e. the problem they tried to solve, rather than the tech details they employed to tune the performance.
The goal of this review is to better understand the role of compilers/IR in data intensive systems.

### TVM: An Automated End-to-End Optimizing Compiler for Deep Learning
TVM is a huge system with multiple essential components.
It originally aims to solve one problem: to deploy deep learning models everywhere -- from raspberry pis to data centers.
Starting from this goal, they proposed a compiler that compiles the graph representation of the model into executable code on target platform.

Having the compiler, they realized the underlying hardware property can significantly change the optimization decisions.
For example, the cache size can fundamentally change the loop size and memory access pattern: matrix multiplication should have smaller tile size on low-end devices than that on server chips. 
Tuning for cache line size is just the beginning of the more complex situation: different hardware backend expose different instructions/intrinsics/memory properties etc,
the engineers are faced with tremendous tunable runtime knobs, and it purely depends on one's prior experience to exploit the hardware resources.
To solve the problem, they proposed a machine learning based program optimizer, which generates optimized the program for new operator workloads and hardware.
The machine learning model can find the best parameter combination based on the hardware backend.

To summarize, in order to generate efficient program for different hardware, TVM proposed a hardware-aware compiler which optimize the graph representation based on the hardware property. 

### Weld: Rethinking the Interface Between Data-Intensive Libraries
We move/materialize data across function calls, which is believed to be a major overhead in data processing pipelines.
A common hand-wired optimization technique is operator-fusion, where we combine operations in multiple loops into multiple operations in single loop. 
While we can improve the performance in this way, it requires non-trivial amount of rewriting and can be counter intuitive.
What's more, it's not possible to fuse operations that across multiple libraries --  a common data processing pattern.

Weld proposed an uniform intermediate representation for common data intensive libraries, claiming that as long as all these libraries are re-written in Weld,
we can eventually benefits from the cross library optimization and lazy-evaluation.
Instead of eager evaluation and materialize the results in memory, Weld allows the operations (map, reduce etc.) to generates intermediate representations.
Weld will then combine these IR (intermediate representations) which enables more opportunities for cross library optimization. 

Lazy evaluation and cross library optimization are not new (LLVM has linking time optimization which does similar jobs), 
Weld for the first time achieved these goals using an IR solution. 


### GraphIt: A High-Performance Graph DSL
The problem is somewhat close to TVM's, where various runtime parameters can impact the system performance, and it's not always feasible to tune the system. 
Instead of using the machine learning based techniques, GraphIt decoupled the algorithm and scheduling,
which enables the opportunities for auto tuning without changing the runtime behaviors.

GraphIt separates what is computed (algorithm) from how it is computed (schedule).
Experienced programmers can write complex and efficient programs by leveraging their expertise to tune the scheduling.
For example, matrix multiplication algorithm is simple, but different implementation can dramatically change the locality and parallelism.
These involved implementation increased the performance but decoupled the algorithm with the scheduling.
GraphIt enables programmers to express their algorithm in simple and intuitive ways, but still allows advanced programmers to optimize their program using scheduling language.

By splitting the algorithm and schedule, GraphIt allows programmers to easily experiment different optimizing tradeoffs and enables future auto-tuning.

