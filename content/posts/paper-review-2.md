---
title: "Paper Review: Concurrency Control"
date: 2020-01-20T16:26:27-08:00
draft: false 
---

### FOEDUS: OLTP Engine for a Thousand Cores and NVRAM

This is a very high-level paper about the overview of a complex system, yet it fits into the category: build a new system using existing components. The paper tried to address two sub topics: 1) database systems that scale to 1000 cores, 2) database systems on NVRAM.

Although the paper claimed to solved the issues, 
I personally did not enjoy reading it because I didn't see a clear logic flow on solving problems.
Rather, it feels more like a system that implemented ABCD, and achieved X performance increase (like an advertisement).
It's good to know people made good attempts on these challenges, but I learned very few things.

Another paper discussed that none of the currency control method scale up to one thousand cores,
while in this paper, it just briefly described the lightweight OCC.
How is this version of OCC scale to 1k cores while others don't?
I personally believe a concurrency control protocol that scale up to 1k cores is enough to make a huge contribution to the community.




### Staring into the Abyss: An Evaluation of Concurrency Control with One Thousand Cores
This paper, however, is a very educational one.
The paper implemented six different concurrency control methods and compare the performance under extremely high contention scenario (1k cores).
The conclusion is that none of these methods scale under the current software-hardware architecture.

I like the paper for being logic complete and well-rounded: 1) the authors showed that simulators have similar results than the real hardware,
2) unrelated factors are properly eliminated, such as allocation and existing DBMS overhead.
These are the major concerns when I'm reading the first part of the paper, and they are all timely addressed. 

When reading the paper, the top question in my mind is: what's the essential difference between 1k cores and 10 cores?
My previous experience is that the amount of data is so large that it's very unlikely for two threads to operate on the same piece of data,
even for the case of 1k cores. After all, 10 cores to 1k cores is *constant* increase.

The paper, however, shows that although it's unlikely that threads contend on actual workload, 
it is tiny synchronizations that limits the whole system, for example, the timestamp allocation.

The paper argues that hardware support is needed for future scalable concurrency control.
The interesting points are: all the hardware modification mentioned in the paper are rather small or even tiny features e.g. hardware counter, 
rather than dramatically redesign the hardware infrastructure to fit the future workload.

Modifications to hardware and make actual impact to the industry, however, is extremely difficult.
Speaking on the other side, with the new forthcoming commercialized hardware features, what can software people do to redesign their systems?


