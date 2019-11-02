---
title: "The case of Persistent CAS"
date: 2019-11-02T12:18:02-07:00
draft: false
---

There are numerous paper talking about persistent memory data structures, some of them claimed excellent performance, others support (near) instant recovery.
But some most important problems are remain unsolved, and even publicly misunderstood, for example, how to do persistent CAS correctly.

Persistent CAS is the most important primitive in building concurrent and crash-consistent data structures. 
In this post, I'll cover the correct ways to build persistent CAS, and report their performance number under different contention level. 

##### CAS operation

Compare and swap, will try to assign `new_v` to `addr` if `*addr == old_v`, namely, CAS.
```c++
CAS(addr, old_v, new_v);
```

In later sections, I will call this method `naive CAS`. Obvisouly `naive CAS` is not crash consistent,
because a crash can happen before the new value is evicted from cache (flushed to memory). 

##### Persistent CAS (FAKE)

A lot of hand wired persistent memory data structures [^1] simply assumes "flushes around CAS" is correct:
```c++
flush();
fence();

CAS(addr, old_v, new_v);

flush(addr);
fence();
```

This assumption is incorrect, as I pointed out in a the previous [post](/posts/crash-consistency).
In later sections, I will call this method `CAS`.


##### CAS with dirty bit
This approach is proposed by [PMwCAS](https://github.com/microsoft/pmwcas), the idea is simple:
```c++
kDirtyMask = 0x8000_0000_0000_0000;

while (old_v is dirty) {
    CAS(target, old_v, old_v & (~kDirtyBitMask));
    old_v = load(addr);
}

new_v_dirty = new_v | kDirtyMask;

CAS(addr, old_v, new_v_dirty);
flush();
fence();
CAS(addr, new_v_dirty, new_v);
```

I named this method as `DirtyCAS`, while `DirtyCAS` is techniqually correct, it has some caveats:

1. It requires readers to clear the dirty bit, which might degrade the reading performance (by issuing extra `store` and polluting the pipeline). 
2. It steals highest bit of the `new_v`, which can be a problem when storing non-pointer values.


##### CAS with logging
The idea is to record the CAS operations before executing them, on recovery, the not flushed CAS will be roll forwarded. A possible implementation can be found [here](https://github.com/XiangpengHao/epoch-reclaimer/blob/master/pcas.h), I call it `PCAS`:

```c++
log(addr, old_v, new_v);
CAS(addr, old_v, new_v);
```

It addresses the issues introduced by `DirtyCAS`, but have a important drawback: it  requires twice more writes than `DirtyCAS` and also issues twice the `flush()`.
The new problem is more severe especially when clwb, a.k.a `flush()`, is [not properly implemented](/posts/is-clwb-implemented).


### Benchmark
Here comes the most boring part, in an ideal world, I would hire someone to do benchmark for me.

All the experiments are performed on [this machine](/posts/new-server). 
In each experiment, each thread is asked to perform 10k CAS operations on a `uint64_t` array, the array has 1k items, and each item is padded to the cache line size.

```
| uint64 ---------- | uint64 ---------- | ... 996 items | uint64 ---------- | uint64 ---------- |
  item 0, 56 bytes    item 1, 56 bytes
```
I did not do the experiment of `pure read`, because it is not a well defined scenario.

Feel free to interpret the results, here are some of mine:

1. The cost of persistency is extremely high, because it effectively bypassed the CPU cache.

2. The performance gap becomes smaller when contention goes high, because cache coherence cost dominates the time (?). 

3. The `DirtyCAS` consistently has slight better performance than `PCAS`, but I believe on read-mostly workload, `PCAS` should be way better (follow up needed!). 

![](/img/cas-exe.png)

![](/img/cas-suc.png)

![](/img/succ-rate.png)

##### Raw data
| exec/s/t | 1           | 2           | 4           | 8           | 16          | 24          |
|--------------|-------------|-------------|-------------|-------------|-------------|-------------|
| PCAS         | 957643.431  | 831690.7441 | 536055.0636 | 362229.5956 | 305126.4291 | 221652.8208 |
| DirtyCAS     | 1224292.91  | 980420.9928 | 830971.9879 | 652686.1298 | 390941.1125 | 263886.36   |
| CAS          | 1928945.368 | 1608399.707 | 1301671.476 | 895134.9416 | 510081.7661 | 349387.6981 |
| NaiveCAS     | 17387040.74 | 5283932.091 | 2794045.331 | 1462033.191 | 736171.0273 | 479356.5118 |

| succ/s/t | 1           | 2           | 4           | 8           | 16          | 24          |
|--------------|-------------|-------------|-------------|-------------|-------------|-------------|
| PCAS         | 957643.431  | 791303.8416 | 467367.648  | 283927.7823 | 198321.4995 | 119742.0257 |
| DirtyCAS     | 1224292.91  | 943081.6593 | 658485.055  | 471941.0233 | 240980.4999 | 149603.1149 |
| CAS          | 1928945.368 | 1608319.287 | 1293015.361 | 846679.0494 | 398200.1127 | 234208.6951 |
| NaiveCAS     | 17387040.74 | 4839236.366 | 2041385.399 | 919982.5579 | 461527.7021 | 293333.4292 |


### Closing words

Supporting persistency will slow down the performance, how much slow-down can you afford? 

What if I don't care crash-consistency, what trade-off can I made?

What if I don't care **strict** crash-consistency, what trade-off can I made?

[^1]:  RECIPE, CCEH etc.
