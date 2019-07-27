---
title: "Modern allocator: mimalloc"
date: 2019-07-26T17:36:49-07:00
draft: true
---

Memory management, especially memory allocation has been a important bottleneck of high performance multi-thread systems.

The following figure shows one my of experiments on high performance in-memory indexes.
![](/img/jemalloc.png)

The experiment is performed on a four-socket machine with 40 physical cores in total.
The yellow line shows the result with jemalloc and grey lines shows the throughput without it.

There're two problems with glibc malloc:

1. It's slower than jemalloc

2. More importantly, it doesn't scale, and it becomes the bottleneck when the number of threads increases.

The problem with `jemalloc` though, is too heavy-weight, the allocator has reached more than 50k loc. AFAIK, most modern high-performance systems (`rust lang`, `firefox`, `pmdk`) has a built-in `jemalloc` or other variants. 

