---
title: "Unaligned mmap can decrease performance, and the lessons learned"
date: 2020-01-25T14:31:39-08:00
draft: false 
---

Several days ago I was told a mysterious bug: 
the performance of our new data structure is unstable across different benchmark execution, specifically, the throughput fluctuates from 1x to 10x.
Further investment shows that the root cause comes from uncommonly high page faults.

There's a long journey to find out the real problem, yet the conclusion is simple:

<div style="font-weight: 700"> Unaligned mmap address can significantly decrease the performance, but it's deceptively easy to mmap an unaligned address, especially for persistent memory.</div>


## Section 1: Unaligned mmap decrease performance

Linux `mmap` will by default align to 4KB, as specified by the system page size.

The persistent memory, however, once [properly configured](https://pmem.io/2018/05/15/using_persistent_memory_devices_with_the_linux_device_mapper.html), is aligned to 2MB to leverage the huge pages.

In other words, if your persistent memory is mapped to a 4KB memory boundary (instead of 2MB), you'll likely to get tremendous extra page faults.

##### Unaligned case 

Consider the following pseudocode, where the `mmap` address is NOT aligned to 2MB:
```cpp
// mmap pool address aligned to 4KB but not 2MB
uint64_t pool_addr = 0x5ff600010000;
pm_pool = pmemobj_create(pool_addr);

auto ret = pmemobj_zalloc(pm_pool, 10GB);
pmemobj_memset(pm_pool, 10GB);
```
Run the code and collect the `perf` result:
```
     6,541,432,706      cycles:u                                                    
       952,076,754      instructions:u            #    0.15  insn per cycle         
           480,752      cache-references:u                                          
           280,847      cache-misses:u            #   58.418 % of all cache refs    
        78,309,630      bus-cycles:u                                                
         1,324,482      page-faults:u   
```

##### Aligned case
Now the `mmap` address is aligned to 2MB (note the only difference in `pool_addr`):
```cpp
// mmap pool address aligned to 2MB
uint64_t pool_addr = 0x5ff600000000;
pm_pool = pmemobj_create(pool_addr);

auto ret = pmemobj_zalloc(pm_pool, 10GB);
pmemobj_memset(pm_pool, 10GB);
```
Run the code and collect the `perf` result (compare the page-faults with the previous one):
```
     5,295,333,275      cycles:u                                                    
       950,777,762      instructions:u            #    0.18  insn per cycle         
           107,143      cache-references:u                                          
            41,122      cache-misses:u            #   38.380 % of all cache refs    
        63,091,836      bus-cycles:u                                                
            16,319      page-faults:u    
```


##### Conclusion

1. It's obvious that unaligned `mmap` can cause serious performance degrade on persistent memory.
2. There's no error, no warning, just transparently caused two orders of more page faults. 
3. There is one indicator, though. When inspecting the `htop`, there're are some dubious cross-socket memory access even if all threads are bind to one socket. The reason is still unknown to me (only some guesses).


## Section 2: mmap is unaware of persistent memory alignment
Now people might think it's ok as long as an 2MB-aligned address is passed `mmap`, this is not always true.
For most `mmap` usage, the address is just a hint, the `mmap` will try its best to map the memory to that address.

However, it can fail in the following two cases:

1. Virtual address occupied. It's very straight-forward that if the specified memory address region is occupied (by other allocation), the `mmap` will definitely fail.
2. The specified address crossed the allowed boundary. This is less known to most people: 
user space address occupies the lower address, while kernel space address uses the higher address. 
And user space address is not allowed to cross that boundary (`0x00007fffffffffff` for 4-level page tables, [reference](https://www.kernel.org/doc/Documentation/x86/x86_64/mm.txt)).

In the previously mentioned bug, I specified the address as `0x00007ff700000000`, for the reason mentioned above, 
this address is not enough to map a pool with size of 200GB, but ok with 20GB pools in my tests.

<div style="font-weight: 700">The mmap will then fallback to find a lower address, however, it does NOT aware of the persistent memory alignment, and ended up mapping to a 4KB aligned address, thus caused the mis-alignment.</div>


## Section 3: Lessons learned, takeaways

1. Cross-socket memory access and high page fault rate is probably caused by memory page mis-alignment.

2. The original PMDK will always return a 2MB aligned address, the Intel guys obviously aware of this trap.
In my fork of PMDK, I added a feature to allow users to specify the address, but most users (including me) didn't know the implications of provided address. 

3. Tests do not always help. During my tests, I always map 20GB of memory and tested it works, 
my mindset was 20GB memory should be more than enough. But in real life, we did use 200GB memory within a single process (crazy).

4. I'll expect far more these bugs in the future systems as we integrate the persistent memory more into our system.
The different alignments, significantly more memory consumption and safe persistency etc will silently break a lot of assumptions. We thus need to be extremely careful, and think critically. 
