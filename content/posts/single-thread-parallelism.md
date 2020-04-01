---
title: "Async memory access (in Rust)"
date: 2020-04-01T14:51:35-07:00
draft: true 
---

## Section 1: Background
We have been using asyncio for years to hide the IO latency.
Major high-level programming languages -- except C++, which is expect to support coroutine in C++20 -- have proper support for both language syntax (programmability) and user space scheduling (functionality).

It's common believe that coroutine has much smaller overhead than the operating system context switch, but we don't yet understand the potential of this "smaller overhead".
The reasons are two folds. First, those high level programming languages (Python, Java, Go) don't really care about "system programming", 
where memory layout and cache friendliness is vital. 
They tend to implement the coroutine with costly stack frames, and in such cases, the implementation overhead varies.
Second, none of the major system programming languages -- especially those with zero-overhead claim languages -- has proper support for coroutine.
Without the joint efforts of language design and compiler optimization, we won't have the chance to push the overhead limit.

Rust is the first challenger.
After years of debating and improving, Rust finally launched its initial stable support for async/await (in Nov 2019).
Rust is also the first programming language that claims "zero-overhead abstraction" on the coroutine support. 
For those who are not familiar with the term "zero-overhead abstraction", here's a definition from the creator of C++:

> What you don't use, you don't pay for (in time or space) and further: What you do use, you couldn't hand code any better.

Previous researches[^1] have shown the vendor-specific coroutine implementations in C++ have the overhead less than a memory access,
in other words, we might be able to use coroutine to bypass the memory stall on cache miss.

In this post, I'll explore how to use Rust to perform async memory access in section 2, 
then I'll present the design and implementation of a minimal scheduler in section 3,
and lastly I'll benchmark the system and perform a micro-architecture analysis to measure the overhead of rust task scheduling.     



[^1]: Exploiting Coroutines to Attack the “Killer Nanoseconds”