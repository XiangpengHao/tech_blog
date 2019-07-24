---
title: "Efficient(correct) way to check a bit value in C/C++ "
date: 2019-07-23T20:04:48-07:00
draft: false
---

It's very common to manipulate data in the bit granularity in high performance systems, 
and checking whether a bit equals to 1 is one of the primary operations.

The way I usually do is:
```c++
#define CHECK_BIT(var, pos) ((((var) & (1 << pos)) > 0) ? (1) : (0))
```
It basically creates a mask and perform an `and` operation against the variable,
it's simple and intuitive enough that I never thought it can be a bottleneck.

**TL;DR, code above is the best possible you can do, so, just trust your compiler.**

But today I came across an very interesting x86 intel intrinsic, `_bittest`, it does **exactly** what `CHECK_BIT` above does.
But it's only one single instruction, and presumably it can greatly boost the performance, and therefore we can make several paper based on it... 

But wait, let me check its performance first.


The first obstacle is I cannot find such intrinsic using gcc or clang!
MSVC has something very similar, but I'm never a fan of it. 
So I finally turned to icc (a crappy intel C++ compiler), and as expected, it compiles. 

Link to it: https://godbolt.org/z/YrSffc

We can interpret the assembly code from two perspectives:

1. The compiler doesn't generate the `bt` instruction by default. 
2. The `_bittest` intrinsic (as well as the generated `bt` instruction) is elegant and concise enough to deliver excellent performance.

I'm more excited about it and can't wait to create a end-to-end benchmark.

Since I only have `gcc` and `clang` installed, I decide to embed assembly code into c++, 
the assembly code, however, is extremely simple:

```c++
inline bool TestBit(uint64_t array, uint64_t bit) {
  bool flag;
  asm("bt %2,%1; setb %0" : "=q"(flag) : "r"(array), "r"(bit));
  return flag;
}
```

Here's the link to mini benchmark: http://quick-bench.com/sI08zBOSeVmsiYJC7jpl4qSxxcU, 
I added some pragma to generate clean assembly code, and it doesn't impact the performance (trust me). 

Sadly and amazingly, the assembly version is actually slightly slower than the naive version. 
As a black magic hobbyist, I've expected lots of mysterious performance fluctuation, 
but this one is simple and clear: the naive version consistently and significantly outperforms the assembly version.

So I digged into the whole assembly code, here's what clang generates:
```asm
33.25% bt     %rcx,%rax
6.13%  setb   %dl
7.63%  mov    %edx,0xc(%rsp)
35.11% add    $0x1,%ecx
3.05%  movzbl %cl,%ecx
3.37%  cmp    $0x40,%ecx
```

Here's what assembly version generates:
```asm
       bt     %rcx,%rax
       setb   %dl
34.20% and    $0x1,%dl
0.19%  movzbl %dl,%edx
32.44% mov    %edx,0xc(%rsp)
32.66% add    $0x1,%rcx
```

The biggest difference is the assembly version will generates an extra `and $0x1, %dl`, which is absolutely unnecessary under this context (but slows down the performance).

So far we draw the conclusions:

1. Compiler(s) are more familiar to the ISA than (most of) you do.

2. Mixing assembly code with C++ might degrade the performance, as it might break the patterns that optimizers trying hard to find.



#### Closing words

Wait, did I say "The compiler doesn't generate the `bt` instruction by default"?

Most compilers (icc, gcc, MSVC) don't, but clang do.

You can select gcc in the mini benchmark to get a reversed benchmark result :)

