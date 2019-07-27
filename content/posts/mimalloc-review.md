---
title: "Modern allocator: mimalloc"
date: 2019-07-26T17:36:49-07:00
draft: true
---

Memory management, especially memory allocation has been a important bottleneck of high performance multi-thread systems.

The following figure shows one my of experiments on high performance in-memory indexes.
![](/img/jemalloc.png)

The experiment is performed on a four-socket machine with 40 physical cores in total.
The yellow line shows the result with `jemalloc` and grey lines shows the throughput with `glibc malloc`.

There're two problems with `glibc malloc`:

1. It's slower than `jemalloc`

2. More importantly, it doesn't scale, and it becomes the bottleneck when the number of threads increases.

The problem with `jemalloc` though, is too heavy-weight, the allocator has reached more than 50k loc. 
AFAIK, most modern high-performance systems ([all rust program](https://internals.rust-lang.org/t/jemalloc-was-just-removed-from-the-standard-library/8759), `firefox`, `pmdk`) has a built-in `jemalloc` or other variants. 

### mimalloc

In respond to these, Microsoft just (May 2019) released a new allocator named [mimalloc](https://github.com/microsoft/mimalloc).

The biggest features of `mimalloc`(form my perspective):

1. Consistently outperform any other allocators
2. Only 3k lines of code.

I'm not going to paraphrase the designs and algorithms in their paper, just to paste some important clips here. 

> Historically, allocator design has focused on performance issues such as reducing the time in the allocator, reducing memory usage, or scaling to many concurrent threads. Less often, allocator design is primarily motivated by **improving the reference locality** of the application.

Key words: **improving the reference locality**

> The main idea is to use extreme free list sharding: instead of one large free list per size class, we instead have a free list per mimalloc page(ususally 64KiB). This keeps locality of allocation as malloc allocates inside one page until that page is full, regardless of where other objects are freed in the heap.

Figures that help to illustrate this process:

For `glibc allocator`:
![](/img/sys-allocator.png)

For `mimalloc`:
![](/img/mimalloc.png)

There're in total three such free lists in each mimalloc page, 
these sharded lists helps to decrease contention and improve locality.

### Future work

As my main research is in-memory index on emerging hardwares (non-volatile memory),
I care more about high-performance allocators that has persistent memory support, `mimalloc`, unfortunately doesn't. 

Enough research shows half of my performance issues comes from persistent allocators,
and I'm looking forward to see anyone (if not me) has new insights on improving allocators.  
