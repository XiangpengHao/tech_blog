---
title: "Paper Review: DB on NIC"
date: 2020-03-16T16:21:05-07:00
draft: true
---

This week's topic is very like the "DB on new hardwares," the difference is NIC has gained some special interests.
The two papers, "HyperLoop" and "NetCache" are very interesting in terms of what problems they tried to solve.

Some unrelated side notes: in the DB seattle report, people complained database conferences (VLDB and SIGMOD) are becoming elite conferences, where the reviewers asking for "perfect papers."
From my point of view, SIGCOMM (where the first paper comes from) indeed is a elite conference, 
which partially explains why the "Hyperloop" paper is extremely satisfying to read.
The "Hyperloop" paper is probably the most enjoyable paper I read in this course (FOEDUS wins the opposite award).

My concerns on NIC computing is programmability: NIC works in much lower level of abstraction, 
we can definitely gain some performance improvements by coupling high level logics with low level implementations, 
but we're also deemed to loose programmability.
Yes it might scale with more machines, but does it scale with more human efforts? 

### HyperLoop: Group-Based NIC-Offloading to Accelerate Replicated Transactions in Multi-Tenant Storage Systems
The first key-word is **Multi-Tenant**, otherwise the paper doesn't make sense.
In a multi-tenant setting (common in cloud computing), CPU resources are **unreliable**, in other words, unpredictable in terms of latency,
thus the second key-word is **Tail-Latency**.

So the complete story is: in a multi-tenant storage system, tail-latency is important yet largely ignored.
The high tail-latency results from unpredictable CPU usage, to eliminate the issue, the authors proposed
a novel architecture that removes CPU from transaction critical path.
An extremely sound and complete story.

How they achieve the same goal without using CPUs are interesting as well. 
The authors repurposed a RDMA operation and combined with other techniques, 
they found it's possible to execute the transaction protocol without involving the CPUs.

I like the word **re-purposing**, it indicates smart and practical methods.

The paper is solid, but we might have some other ways to solve the problem.
If we decide to remove the CPU from critical paths, programmable NIC shouldn't be the only answer.
FPGAs should also work in this case, as we discussed before, FPGAs can definitely help with tail latency thanks to the deterministic hardware design.
But removing the CPU completely is quite aggressive and not economical.
If the main overhead comes from CPU scheduling/context switch, does it indicate something fundamental is broken in our current software computation model?   
Can we approach the same goal without touching any hardware?
Or, does the end of Moore's law directly leads to the spring of domain-specific hardwares?
I don't know.

(last words, I bookmarked this paper to learn how to write papers.)


### NetCache: Balancing Key-Value Stores with Fast In-Network Caching
The second paper discuss how to use NIC to address skew-workloads and eventually address load balancing. 
I don't have much so say about this paper, honestly I've seen tons of similar work (this paper is probably one of the earliest?)

Overall, good to know.

<del>Just because our NIC suddenly becomes programmable doesn't mean we need to re-build everything on top of it.
</del>

<del>I'm not saying it's a bad paper or too progressive paper. It's just that I want to set a higher bar for myself, so that I can end up producing mediocre papers. (Chinese version: 取乎其上，得乎其中；取乎其中，得乎其下；《论语》)</del>

