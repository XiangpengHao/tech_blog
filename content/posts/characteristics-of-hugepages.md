---
title: "Characteristics of Huge Pages"
date: 2019-07-29T17:09:36-07:00
draft: false 
---

This post is more like a cheat sheet for huge pages, some details need to be updated later.

The virtual-to-physical address translation overhead,a major performance bottleneck for modern workloads, can be effectively alleviated with huge pages. [^1]



The page size in modern operation system is 4KiB, which is considered too small for large memory workloads.

Using huge pages can minimize CPU time spent in performing page table lookups by reducing TLB misses.[^2] [^4]

![huge table](/img/huge-page.png)

### Huge page sizes

2MiB (likely) or/and 1GiB, AFAIK, no other options.

### Hardware support

Huge page needs hardware support, however, it has been implemented for decades, in other words, it's supported in most x86 CPUs.

### Huge page features

1. Huge pages will never be swapped out.

2. The memory reserved by huge pages can only be utilized by processes that are huge page aware.

3. Huge pages are pre-allocated/reserved on system boot, they cannot be used for other purpose(e.g. convert to normal pages).


### Huge page vs Transparent Huge Page (THP)

They are different things, though people often confuses these two (even in some peer-reviewed academic papers[^1])

>Huge pages can be difficult to manage manually, and often require significant changes to code in order to be used effectively. As such, Red Hat Enterprise Linux 6 also implemented the use of transparent huge pages (THP). THP is an abstraction layer that automates most aspects of creating, managing, and using huge pages. [^3]


### Problems with THP

It dynamically allocates huge page from heap, which may cause extra memory movement due to memory fragmentation, thus cause very high latency on page fault.

(To make things worse, some kernel pages are unmovable thus pollutes the contiguous physical memory [^1] [^4])

>THP hides much of the complexity in using huge pages from system administrators and developers. 
>As the goal of THP is improving performance, its developers (both from the community and Red Hat) have tested and optimized THP across a wide range of systems, 
>configurations, applications, and workloads. This allows the default settings of THP to improve the performance of most system configurations. 
>**However, THP is not recommended for database workloads.**[^3]


### My words

We (high performance systems) should always use huge pages when possible.

Page table is evil, we should (eventually) get rid of it, and huge page is the first step.

Modern kernel should have a "direct mode", in which applications ask for memory on startup and then have direct access to physical address (instead of traversing multiple page tables on every dereference).





[^1]: Making Huge Pages Actually Useful 

[^2]: Efficient virtual memory for big memory servers 

[^3]: [HUGE PAGES AND TRANSPARENT HUGE PAGES](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/performance_tuning_guide/s-memory-transhuge)

[^4]: Coordinated and Efficient Huge Page Management with Ingens


{{ template "_internal/disqus.html" . }}

