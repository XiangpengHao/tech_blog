---
title: "Performance Comparison of Different Allocators"
date: 2019-08-26T15:41:57-07:00
draft: false 
---

Update:
Fix incorrect legend, thanks Baotong! 

I have some stereotypes on different allocators, for example, `jemalloc` is the best allocator, `glibc malloc` doesn't scale, `pmdk allocator` is slow and don't scale. 
But I don't have any results to vindicate my impressions. 

The following experiments are designed to convince you.

### Workload

Workload: to allocate 1024 bytes of memory and repeat 1024 times per thread, each allocation need to be `zalloc`(zero alloc), in other words, every allocation is followed by a `memset(ptr, 0, len)` (unless the allocator has explicit `zalloc` function).

I observed similar trends for other allocation size classes (256-byte and 512-byte), so only  result for 1024-byte allocation is reported. 

As PMDK allocator is designed for persistent memory, and any other allocators are only for DRAM, all the experiments are performed on the DRAM. 
PMDK allocator experiments are executed under volatile mode (`PMEM_IS_PMEM_FORCE=1`).


### Results

| Allocator -  Threads | 1          | 2          | 4          | 8          | 16         |
|--------------------|------------|------------|------------|------------|------------|
| PMDK:transaction   | 0.0268854  | 0.0274951  | 0.0308931  | 0.0349187  | 0.0517541  |
| PMDK:atomic+memset | 0.0239571  | 0.0262208  | 0.0301267  | 0.0335501  | 0.0577313  |
| PMDK:zalloc        | 0.022262   | 0.0249357  | 0.0263771  | 0.030475   | 0.0526358  |
| glibc malloc        | 0.00748696 | 0.0223663  | 0.0390622  | 0.0945179  | 0.191004   |
| glibc malloc:clwb   | 0.00877399 | 0.017572   | 0.0382765  | 0.0817171  | 0.175284   |
| jemalloc           | 0.00588073 | 0.00788947 | 0.00862106 | 0.00937587 | 0.0118319  |
| jemalloc:clwb      | 0.00776278 | 0.00800598 | 0.00825322 | 0.00907541 | 0.0107397  |
| mimalloc           | 0.00723632 | 0.00731957 | 0.00710836 | 0.00719447 | 0.00933608 |
| mimalloc:clwb      | 0.00723788 | 0.00739142 | 0.00738589 | 0.00769756 | 0.00954164 |

![](/img/allocator_bench.png)


### Takeaway

1. `glibc malloc` is essentially single-threaded.

2. `PMDK allocator` is constantly slower than `jemalloc`, but scales under DRAM. (`PMDK allocator` is based on `jemalloc`).

3. The difference between zalloc, transactional alloc, atomic alloc in `PMDK allocator` is insignificant. 

3. Both `jemalloc` and `mimalloc` performs well under this specific workload.

4. `clwb` doesn't have much impact on the allocation itself.


### Bonus

Since PMDK allocator is the only publicly available allocator that supports allocation on Intel DCPMM, I migrated the same experiments to the persistent memory, and here's the result.

| Allocator - Threads         | 1        | 2        | 4        | 8        | 16       |
|--------------------|----------|----------|----------|----------|----------|
| PMDK:transaction   | 0.185967 | 0.186106 | 0.209842 | 0.271591 | 0.384797 |
| PMDK:atomic+memset | 0.187867 | 0.187743 | 0.209595 | 0.270529 | 0.385283 |
| PMDK:zalloc        | 0.146668 | 0.155793 | 0.200465 | 0.275339 | 0.406135 |

![](/img/pmdk-allocator.png)

I used column chart because otherwise the `PMDK:transaction` and `PMDK:atomic+memset` will become undistinguishable.


The following figure compares the same allocator running on different devices:

![](/img/alloc_dram_optane.png)
