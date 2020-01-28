---
title: "Paper Review: Indexing"
date: 2020-01-27T14:32:18-08:00
draft: false 
---

Key words: many-core, latch-free, cache, memory

### The Bw-Tree: A B-tree for New Hardware Platforms
BwTree is a b+tree trying to fit with multi-core processor and flash based storage.
To deal with multi-core processors the authors argued we ultimately need to achieve latch-free in order to eliminate the thread synchronization cost.
To co-operate with the flash storage, the BwTree utilized the mapping table as the base for other innovations, such as delta updating and less internal node modifications.

Latch-free is one of the most common words in the paper, probably because back to 2013 people tend to agree that lock based synchronization does not scale to many-core cpus.
So the latch-free paradigm becomes the new hot topic. 
Yet from the 2020 point of view, there're less paper talking about latch-free algorithms.

There are at least three reasons for that:
1. Latch-free is too complex to get correct. The implementation requires thread help-along, while it's extremely difficult to test every possible cases.
2. The benefits of being latch-free is not large enough to out-perform its complexity cost.
3. Most thread help-along does not produce meaningful work, rather they have side effects: consumes too much memory bandwidth thus leaves less resources to the remaining of the system.


Speaking of index for new hardware, my favorite in-memory index tree is the ART.
Although the ART paper only highlighted the tricks they used to reduce memory consumption, the implication of the overall design is deep and profound.
On the one hand, they achieved almost optimal information gain per cache line visit by storing the keys implicitly along the query path.
This means that each query requires less memory load to traverse the tree and thus saves a lot of bandwidth.
On the other hand, the lazy expansion is actually prefix-compression, 
i.e. in most query cases the thread only need to load a portion of the key to reach the leaf node.


### PALM: Parallel Architecture-Friendly Latch-Free Modifications to B+ Trees on Many-Core Processors

The key idea of this paper is Bulk Synchronous Parallel, which is common in graph processing but less so in database indexes.
The paper used BSP to avoid race conditions and deadlocks, at the cost of tail latencies. 
What's more, the thread model has quite deviated from the traditional transaction-based thread model.
In this paper, there's a group of threads dedicated for the index, i.e. these threads all in a thread pool that cannot be reused by other work.
This thread model significantly limited the usage of this index as it's incompatible with the remaining system.
This paper, however, is insightful in terms of exploring the usage of BSP in in-memory indexes. 

The paper only evaluated the performance within 12 cores, and I'm extremely skeptical to the scalability of the whole system, as there's a global `sync` after step 1,
which can be a major bottleneck once the core count increase to a practical count.

Also notice that all the evaluations in the paper are with 4-byte keys, which is unrealistic in real world scenarios and gives SIMD acceleration unfair advantages.

What's more, the latency evaluation shows that 99% peak throughput has 350 us latency.
To the best of my knowledge, most in-memory indexes has less than 10 us read latency at 99% throughput.
Yet the authors claimed "These response time are low enough to allow our scheme to be used even in real-time databases."

Nevertheless, it's good to know people trying to integrate BSP into range indexes.
(I would hope they perform more comprehensive evaluations though, even if the idea doesn't actually work)
