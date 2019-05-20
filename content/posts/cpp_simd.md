---
title: "Tutorial: SIMD in C++ "
date: 2019-05-19T22:54:49-07:00
draft: false 
---

## SIMD Background
SIMD (Single Instruction Multiple Data) is a term refers to *instruction-level parallelism*, one register carries multiple data and do the computation during a single instruction. The following figure shows the different level of parallelism.

![level-para](/img/level-para.png)

Multi-thread programming (task level) is known to have very high overhead, especially on small task parallelism, while SIMD (instruction level) has almost zero overhead on CPU.



## Do I need it?

No. Trust your compiler and do nothing. Modern compilers are intelligent enough to detect most loop patterns that can be paralleled, and the compilers are smart enough to perform profitable optimization under the hood. With that said, some *optimization* may actually hurt the performance, we'll show in later sections.

What's more, SIMD instructions are not supported by all platforms. 



## A small example

Consider a simple array sqrt example. In plain c++ the code can be as simple as:

```c++
 void array_sqrt(float *a, int N)
 {
     for (int i = 0; i < N; ++i)
         a[i] = sqrt(a[i]);
 }

```

We simply loop over the array and compute the sqrt of each item then write back to the array.

Re-write the function using the SIMD instructions:

```c++
 void array_sqrt_opt(float *a, int N)
 {
     __m128 *ptr = (__m128 *)a;

     for(uint32_t i = 0; i < N/4; i++){
         _mm_store_ps(a, _mm_sqrt_ps(*ptr));
         ptr += 1;
         a += 4;
     }
 }

```

The first line cast a float array to a `__m128` array, `__m128` is a register that can hold 128 bits of data, in our case, 4 floating numbers.

Compile the code with following command:

```bash
 g++ ../simd.cc -o simd -O3 -march=native
```

`-O3` enables all optimization, `-march` allows the compiler using the native ISA.

![1558335250057](/img/1558335250057.png)

Here we go.





## Bonus

##### Enable `-Ofast`:

![1558335420257](/img/1558335420257.png)



##### Using `clang`:

![1558335477506](/img/1558335477506.png)