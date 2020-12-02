---
title: "Is CLWB actually implemented?"
date: 2019-11-04T14:16:45-07:00
draft: false 
---

TLDR: No. `clwb` is just an alias of `clflushopt` on `Cascadelake`.  

### What is clwb, clflushopt, clflush?

It sounds crazy, but before `clflush` there isn't a instruction on Intel `x86` platform that can explicitly evict a cacheline.
In other words, applications has no control of when their data should be flushed to memory.

So Intel came up with their own solution, namely `clflush` (cache line flush), which flush a cache line.

Though not explicitly mentioned, `clflush` not only writes a cache line to memory, but also eivcts the memory from the cache line, 
what's more, it will issue a hidden `mfence`.

These two side-effects can have huge negative impacts on the performance, especially the hidden `mfence`, which stalls the cpu pipeline and materializes all store instructions.

For compatibility concerns, Intel did not remove the `mfence` from `clflush`,
 instead they introduced a new instruction called `clflushopt` (Skylake, 2018), which writes back the memory, evict the cache line but do not issue `mfence`. 

But `clflushopt` still far from ideal because it evicts the cache line which makes it inefficient when writing back hot memory. The problem gets worse with the advent of persistent memory, where `clflushopt` is mandatory for correctness and often used in hotpath.

Again for compatibility reasons, Intel decided to introduce a new instruction on `Cascadelake` (2019), called `clwb`, which does everything `clflushopt` does, but it reserves the right to preserve cache lines. 

### Does it really work?
Intel [says](https://www.felixcloutier.com/x86/clwb):
>Retaining the line in the cache hierarchy is a performance optimization (treated as a hint by hardware) to reduce the possibility of cache miss on a subsequent access. Hardware may choose to retain the line at any of the levels in the cache hierarchy, and in some cases, may invalidate the line from the cache hierarchy. The source operand is a byte memory location.

*Retaining the line in the cache hierarchy is a performance optimization*,
in other words there's no guarantee that `clwb` can retain the cache line, it's just an performance optimization.

To allow applications to manually flush cache lines, 
Intel took more than five years to propose three different instructions, and yet none of them work perfectly.

<img src="/img/intel-clwb.jpg" width="200"/>

### Let's test it

My first test was to simply issue these instructions and compare the time of memory access. All the experiments are performed under `performance mode`, `O3` and with all hardware prefetchers disabled. 

Code to reproduce my results: 
https://gist.github.com/XiangpengHao/ddd63d6f6dc60d701583aae4c838787f

![](/img/clwb-clflush.png)

1. There's no significant difference between `clwb`, `clflushopt`, `clflush`, and they all slower than reading from cache.

2. There's no significant difference between temporal read and non-temporal read.
This indicates that the CPU will check the cache even for non-temporal reads

Looks like `clwb` isn't really helpful at retaining cache (at least in the CascadeLake).

To confirm this, my second test used `perf` to directly count the cache misses.

| | Cache Miss | Cache Reference |
| ----- | ----- | -----|
| Cache access | 440,054 | 734,891 |
| Non-temporal access | 450,768 | 735,937 |
| `clwb` then non-temporal | 688,824 | 740,203 |
| With `clwb`| 692,845 | 737,919 |
| With `clflushopt`| 687,392 | 736,697 |
| With `clflush`| 688,151 | 736,890 |

`clwb` and `clflushopt` have similar cache reference and cache miss --
which means `clwb` is just an alias of `clflushopt` on their latest server CPU, shame on Intel!


Update 12-02-2020:
rewrite some sentences to improve clearity.

Update 11-04-2019: 
clwb will evict the cache line even if it's **NOT** dirty.


