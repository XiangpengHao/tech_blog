---
title: "A possible mmap bug from Linux kernel"
date: 2020-02-06T13:51:49-08:00
draft: false 
---

I'm never a fan of Linux kernel design, especially the lack of configuration validation.
Among all the ill-designed system calls, `mmap` is probably the worst and the most out-of-control one.

### The theory

Before I talk discuss about today's bug, here's a little bit background: https://lwn.net/Articles/758594/

> mmap() is not allowed (by standards like POSIX by many years of history) to return an error when given unknown flags... More serious is that there is no way for an application to know that the kernel it's running on at the moment supports MAP_SYNC at all, since all kernels will return success with that flag set. Any application that is depending on MAP_SYNC to ensure the integrity of its data needs to know for sure that the feature is supported, but mmap() provides no way to obtain that knowledge. (MAP_SYNC is just one of the recently added flags) 

People realized that applications should have some mechanisms to validate the flags passed to `mmap`, 
so kernel guys proposed a `_VALIDATE` postfix, specifying any flags ended with `_VALIDATE` will return an error if other unknown flags was encountered. (fact: there's only one new flag has this postfix, named `MAP_SHARED_VALIDATE`)

Ironically, this new flag (`MAP_SHARED_VALIDATE`) caused some new issues.
Date back to kernel 4.15 when `MAP_SHARED_VALIDATE` was proposed, the implementation maintained a variable called `LEGACY_MAP_MASK` ([this](https://github.com/torvalds/linux/blob/master/include/linux/mman.h#L35) and [this](https://github.com/torvalds/linux/blob/master/mm/mmap.c#L1450)) to filter known flags.

When kernel version bumps to 4.17, however, `mmap` was extended to support a new feature called `MAP_FIXED_NOREPLACE`, but for the above reason, `MAP_FIXED_NOREPLACE` will be identified as unknown flags when combined with `MAP_SHARED_VALIDATE`.

The most ergonomic proposal for a new mmap flag should include two different versions, in this case,
`MAP_FIXED_NOREPLACE` and `MAP_FIXED_NOREPLACE_VALIDATE`, the latter will validate other co-existing flags while the first one don't. (fact: as you might guess, there's a flag called `MAP_FIXED`.)


### Get hands dirty

We know the story and the background, let validate it. 

The idea is simple: `MAP_SHARED_VALIDATE` is incompatible with `MAP_FIXED_NOREPLACE`, while other combinations should all work.

Running the following code by

```bash
clang++ test_mmap_validate.cpp -o test_mmap_validate && ./test_mmap_validate
```

The result is clear
```
MAP_SHARED_VALIDATE | MAP_FIXED:                0x4f0000000000
MAP_SHARED_VALIDATE | MAP_FIXED_NOREPLACE:      unknown flags    0xffffffffffffffff
MAP_SHARED | MAP_FIXED:                         0x4f0000000000
MAP_SHARED | MAP_FIXED_NOREPLACE:               0x4f0000000000
```


<script src="https://gist.github.com/XiangpengHao/2557d54dd609cc351d1a76842cfd4d2c.js"></script>


