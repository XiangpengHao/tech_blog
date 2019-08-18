---
title: "Is CLWB really implemented?"
date: 2019-08-17T18:16:45-07:00
draft: false 
---

No. `clwb` is just an alias of `clflushopt` on `Cascadelake`.  


### What is clwb, clflushopt, clflush?

It sounds crazy, but before `clflush` there isn't a instruction on Intel `x86` platform that explicitly evict a cacheline.
In other words, applications has no control of when their data will be flushed to memory.

So Intel came up with their own solution, namely `clflush` (cache line flush), which flush a cache line.

Though not explicitly mentioned, `clflush` does not only flush a cache line, but also invalidates the cache line, 
what's more, it will issue a hidden `mfence`.

These two side-effects can have huge impact on the performance, especially the `mfence`, which stalls the cpu pipeline and materializes all store instructions.

For compatibility concerns, Intel did not remove the `mfence` from `clflush`,
 instead they introduced a new instruction called `clflushopt` (Skylake, 2018), which simply is a `clflush` without `mfence`. 

But people still complain about cache eviction of `clflushopt`, especially in the era of persistent memory, where `clflushopt` is used everywhere.

Again for compatibility reasons, Intel decided to introduce a new instruction on `Cascadelake` (2019), called `clwb`, which does everything `clflushopt` does, except for preserving the cache line. 

### Really?

>Retaining the line in the cache hierarchy is a performance optimization (treated as a hint by hardware) to reduce the possibility of cache miss on a subsequent access. Hardware may choose to retain the line at any of the levels in the cache hierarchy, and in some cases, may invalidate the line from the cache hierarchy. The source operand is a byte memory location.

Intel [said](https://www.felixcloutier.com/x86/clwb): Retaining the line in the cache hierarchy is a performance optimization. So there's no guarantee that `clwb` can retain the cache line, it's just an performance optimization.

To allow applications to manually flush cache lines, 
Intel took more than five years to propose three different instructions, and yet none of them did it perfectly.

<img src="/img/intel-clwb.jpg" width="200"/>

### Let's test it

My first test was simply to issue these instructions and compare the time of memory access. All the experiments are performed under `performance mode`, `O3` and with all hardware prefetchers disabled. 

![](/img/clwb-clflush.png)

1. There's no significant difference between `clwb`, `clflushopt`, `clflush`, and they all slower than reading from cache.

2. There's no significant difference between temporal read and non-temporal read.
This indicates even for non-temporal read, the cpu will still check the cache. 


Looks like `clwb` isn't really helpful.

To confirm this, my second test used `perf` to directly count the cache misses.

| | Cache Miss | Cache Reference |
| ----- | ----- | -----|
| Cache access | 440,054 | 734,891 |
| Non-temporal access | 450,768 | 735,937 |
| `clwb` then non-temporal | 688,824 | 740,203 |
| With `clwb`| 692,845 | 737,919 |
| With `clflushopt`| 687,392 | 736,697 |
| With `clflush`| 688,151 | 736,890 |


Looks like `clwb` is just an alias of `clflushopt`, shame on Intel!


