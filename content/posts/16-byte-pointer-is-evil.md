---
title: "16 Byte Pointer Is Evil"
date: 2019-08-01T20:20:02-07:00
draft: true
---

You've probably never heard of 16-byte pointers, but that's what happening in persistent memory programming model, and especially you, [PMDK](http://pmem.io/pmdk/).


The idea behind 16-byte pointer is very simple:
```c++
struct pm_ptr{
    void* pool_addr;
    uint64_t offset;
}
```

The first 8-byte part of the `pm_ptr` simply points to the persistent memory pool.
The other 8-byte offset shows the location of the object relative to the memory pool.

In other words, to compute the real and normal address of the object, you need to add them up, which is:
```c++
void* get_direct(pm_ptr ptr){
    return ptr.pool_addr + ptr.offset;
}
```

This is probably the easiest way to support persistent memory, and also the worst possible way. 

### Performance

This is the least important thing, but it does require an extra `add` on every `load` and `store`.

It also occupies more memory as well, thus takes more memory traffic and make cache less effective.

### Compatibility

It introduces huge amount of difficulties for developers who want to build applications that support both DRAM and NVM.

Every time a programmer touches the pointer, he/she needs a dedicated logic to handle each case, 
it's more painful than supporting different operating systems, where you can wrap the environment-specific syscalls and everything else remains the same.
In nvm, instead, having bigger pointer leads to a different structure (class/struct) layout, 
in the worst case you might need to re-design you data-structure in order to be cache-efficient. 

### Concurrency

This is the most critical issue, 16-byte-pointer just completely closed door for lock-free concurrency.

Lock-free concurrency control takes advantage of 8-byte hardware atomic operations, and build complex logic on top of it. 
16-byte-pointer just make all these efforts less useful.

High performance systems don’t build lock-free data-strictures just to make software developers’ lives interesting.
Rather, lock manager is the new bottleneck for modern in-memory database systems.

And more importantly, latch-free is the only way to go in persistent memory era (not going to explain this here), unless logging system is implemented.

[PMDK](http://pmem.io/pmdk/) forces you to log everything, every operations.


### Other ways?

Yes. The problem can be solved by mapping the persistent memory pool to the same address across different runs.

By doing this, `pool_addr` in `pm_ptr` will remain the same, thus you can simply use the `pool_addr + offset` as the new pointer.

8-byte, Simple and Clean.

The only concern is you might fail to always map the pool to the same address.

But fortunately we can, that's where we leverage the power of virtual memory.

Live demo: [my patch of PMDK](https://github.com/HaoPatrick/pmdk/tree/addr-patch) which supports to map memory pool to a specific memory address.

