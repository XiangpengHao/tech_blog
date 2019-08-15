---
title: "How fast is Intel DC Persistent Memory Module?"
date: 2019-08-14T15:29:21-07:00
draft: false 
---


TL;DR: Slow, SSD-level.

More details checkout [this paper](https://arxiv.org/abs/1903.05714).

![](/img/optane.jpg)


I only measured write performance, using the tool [`pqos-os`](https://github.com/intel/intel-cmt-cat/wiki/Usage-Examples) by Intel.

### System Configuration

| Item | Spec |
| ----- |:-----:|
| CPU | [Intel(R) Xeon(R) Gold 6252 CPU @ 2.10GHz](https://en.wikichip.org/wiki/intel/xeon_gold/6252) * 2 |
| DRAM | 2666 MHz - 6 * 32 GB * 2  |
| Intel DCPMM | 2666 MHz - 4 * 128 GB * 2 |
| Linux Distro/Kernel | Arch Linux - 5.2.7 |


### Bandwidth (sequential write)

| Item | Spec |
| ----- |:-----:|
| DRAM Local | 75 GiB/s |
| DRAM Remote | 27 GiB/s |
| Intel DCPMM Local | 8.5 GiB/s |
| Intel DCPMM Remote | 4.5 GiB/s |


##### DRAM Bandwidth

DRAM Remote max bandwidth is about 1/3 of DRAM Local's.

Before 10 threads, DRAM Remote bandwidth is about 1/2 of DRAM Local's. Because better UPI?

##### Intel DCPMM Bandwidth
Three threads are enough to full-fill Intel DCPMM local bandwidth, and the bandwidth slightly decreases afterwards.

When using small (<3) amount of threads, remote Intel DCPMM bandwidth is about 1/4 of local's, the ratio gradually reaches to 1/2 before 6 threads. 
After 7 threads the performance dropped by 50%, and it continues to drop and converges to ~700 MiB/s (slow!!!).

The penalty of none-uniform-pm access is much higher than none-uniform-dram access.



![](/img/write.png)


### Optane Tricks (Dragon warning!)

The question is "How do you test memory write performance?"

| Name | Impl. |
| ----- |:-----:|
| glibc memset | <pre>`memset(dst, 1, len)`</pre>|
| with clwb | <pre>`memset(dst, 1, len)``_mm_clwb(dst)`</pre>|
| with clflushopt | <pre>`memset(dst, 1, len)``_mm_clflushopt(dst)`</pre>|
| with clflush | <pre>`memset(dst, 1, len)``_mm_clflush(dst)`</pre>|
| avx512 tp | <pre>`_mm512_store_si512((__m512i*)dst, c)`</pre>|
| avx512 tp + clwb | <pre>`_mm512_store_si512((__m512i*)dst, c)``_mm_clwb(dst)`</pre>|
| avx512 nt | <pre>`_mm512_stream_si512((__m512i*)dst, c)`</pre>|
| pmem_memset | <pre>`pmem_memset_nodrain(dst, 1, len)`</pre>|

![](/img/memset-optane.png)


##### Observations 

1. Intel DCPMM performs the best on sequential, read/write-only workload [^1].

2. Application developers should always take control of the cache write back, instead of delegating it to the CPU cache controller.


[^1]: Basic Performance Measurements of the Intel Optane DC Persistent Memory Module