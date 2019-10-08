---
title: "Performance Comparison of Different Allocators"
date: 2019-08-26T15:41:57-07:00
draft: false 
---
Update 10-8:
Add numbers for 24 threads

Update 8-27:
Fixed the incorrect legend, thanks Baotong! 

I have some stereotypes on different allocators, for example, `jemalloc` is the best allocator, `glibc malloc` doesn't scale, `pmdk allocator` is slow and don't scale. 
But I don't have any results to vindicate my impressions. 

The following experiments are designed to convince you.

### Workload

Workload: to allocate 1024 bytes of memory and repeat 1024 times per thread, each allocation need to be `zalloc`(zero alloc), in other words, every allocation is followed by a `memset(ptr, 0, len)` (unless the allocator has explicit `zalloc` function).

I observed similar trends for other allocation size classes (256-byte and 512-byte), so only  result for 1024-byte allocation is reported. 

As PMDK allocator is designed for persistent memory, and any other allocators are only for DRAM, all the experiments are performed on the DRAM. 
PMDK allocator experiments are executed under volatile mode (`PMEM_IS_PMEM_FORCE=1`).

All the experiments are performed on [this](/posts/new-server) machine.


### Results

| Allocator -  Threads | 1          | 2          | 4          | 8          | 16         | 24|
|--------------------|------------|------------|------------|------------|------------|-------|
| PMDK:transaction   | 0.0268854  | 0.0274951  | 0.0308931  | 0.0349187  | 0.0517541  |0.0865849|
| PMDK:atomic+memset | 0.0239571  | 0.0262208  | 0.0301267  | 0.0335501  | 0.0577313  |0.0872701|
| PMDK:zalloc        | 0.022262   | 0.0249357  | 0.0263771  | 0.030475   | 0.0526358  |0.0911465|
| glibc malloc        | 0.00748696 | 0.0223663  | 0.0390622  | 0.0945179  | 0.191004   |0.34755|
| glibc malloc:clwb   | 0.00877399 | 0.017572   | 0.0382765  | 0.0817171  | 0.175284   |0.330139|
| jemalloc           | 0.00929433 | 0.00966189 | 0.0100245 | 0.0109757 | 0.0140428  |0.0196574|
| jemalloc:clwb      | 0.00960622 | 0.0103752 | 0.0108871 | 0.0117046 | 0.013841  |0.0178645|
| mimalloc           | 0.008439 | 0.00866646 | 0.00882467 | 0.00951377 | 0.0138434 |0.0204305 |
| mimalloc:clwb      | 0.0101693 | 0.0100679 | 0.0101334 | 0.0106114 | 0.0134876 |0.019413|

![](/img/allocator_bench.png)


### Takeaway

1. `glibc malloc` is essentially single-threaded.

2. `PMDK allocator` is constantly slower than `jemalloc`, but scales under DRAM. (`PMDK allocator` is based on `jemalloc`).

3. The difference between zalloc, transactional alloc, atomic alloc in `PMDK allocator` is insignificant. 

3. Both `jemalloc` and `mimalloc` performs well under this specific workload.

4. `clwb` doesn't have much impact on the allocation itself.


### Bonus

Since PMDK allocator is the only publicly available allocator that supports allocation on Intel DCPMM, I migrated the same experiments to the persistent memory, and here's the result.

| Allocator - Threads         | 1        | 2        | 4        | 8        | 16       | 24 |
|--------------------|----------|----------|----------|----------|----------|------|
| PMDK:transaction   | 0.198506 | 0.203951 | 0.229829 | 0.309981 | 0.43601 |0.608642|
| PMDK:atomic+memset | 0.199005 | 0.201753 | 0.228247 | 0.309207 | 0.433212 |0.608619|
| PMDK:zalloc        | 0.161741 | 0.17158 | 0.209894 | 0.312658 | 0.449119 | 0.574593 |

![](/img/pmdk-allocator.png)

I used column chart because otherwise the `PMDK:transaction` and `PMDK:atomic+memset` will become undistinguishable.


The following figure compares the same allocator running on different devices:

![](/img/alloc_dram_optane.png)
