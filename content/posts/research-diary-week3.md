---
title: "Research Diary Week 3"
date: 2019-07-12T12:08:58-07:00
draft: false 
---

### July 19th

First of all, happy birthday!

I spent my whole day struggling with a very strange bug...

My implementation is cursed by lock-free concurrency, I totally absolutely have no idea why it does work,
and I've tried all my possible ways trying to figure it out (but failed).

I spend two hours to reproduce the bug, and another two hours to locate the possible causes,
and yes again, another two hours just to find they are perfectly fine.

I might be a little bit too rush to finish the implementation, I should calm down and use my brain to debug, even harder.



### July 18th
My research progress is a bit slower than I expected, anyway, no much progress today.


### July 17th
I was a fan of recursive programming, I liked to write recursive code that literally nobody understand.

But that's not the pattern for persistent memory programming. 
Recursions have implicit single-direction data dependency, say, A -> B -> C -> D, while in most cases of persistent memory/lock free programming, there's no such easy, single-direction data dependency, 
because the logic for current state will largely depend on the previous state, or it's common to frequently check the previous state.

Say when a thread read a value `A`, and based on the value read, the thread performed some computations, these computations are valid only when `A` stays unchanged.
So before the new computations can be committed, the thread need to check the state of previous value (at least).

That is where the circular data/logic dependency exists, and this dependency breaks the recursion.

I'm painfully rewriting some of my recursive code to their loop-based ones, so that when state changes, it's easier to access the previous states.


### July 16th
Check out my talk today [numa-aware-bench-result](/pdf/numa-aware-bench-results.pdf)[^1], basically discuss about some common factors that will impact the performance of a multi-thread system.

Take away: (even) for trivial workload, it's not always beneficial to go multi-thread, [`false-sharing`](https://en.wikipedia.org/wiki/False_sharing) and `NUMA-effects` will limit the concurrency.

Multi-thread system is hard to implement correctly, let alone efficiently. 

Very subtle implementation differences will have huge impact on overall performance, that's the root of all evil. 


[^1]: `cacophony` is part of my new project, so just ignore it.


### July 15th
Today implemented the benchmark and will present the results to Keval tomorrow.

I tried Google Benchmark but finally decide to get rid of it. 
The problem with Google Benchmark is they seems to have very mysterious and complex concepts, which, introduces more difficulties to explain the already black-boxed benchmark results.

So I decide to make a new benchmark wrapper from scratch, I don't like it, but it's the state of C++ echo system, people like to re-invent everything and just don't trust most third party libraries.
This is partly because users of C++ tends to care quite different aspect of the language, some cares more on programmability, some cares more about performance. 
These people simply can not reach agreement on most design choices.

As for me, performance is always the first-class citizens, 
I understand there're so many factors that can impact overall performance, so I just don't trust most people's implementation,
and would like to review every lines of code in my project if possible.

Some other thoughts: latch-free programming is really energy-consuming. It's meaningless and don't worth the efforts.


### July 12th

There's a very famous research pattern in the system group, people do experiment-oriented research.

I personally don't like this way of researching, for the following reasons:

1. Mini experiments/benchmarks have very limited insights, sometimes they even point to the opposite direction.
The problem with mini benchmark is small factors/optimizations get magnified, unimportant issues become dominant, and true vital things are thus hidden by them. 

2. It's really really difficult to implement a mini benchmark correctly, there're just tons of things you need to consider in order to simulate the real workload. 
Cache miss, numa effect, CPU pipeline, compiler optimization etc, after you take all these things into consideration, your mini benchmark will grow as much complex as your final implementation (if not more). 

3. More importantly, researching (in my mind), is not about calling `perf` and increase the performance by 15% by reducing a cache line access.
Benchmarking will make you short-sighted, you'll always think about progressively improve the performance, rather than thinking about big pictures and big ideas.



