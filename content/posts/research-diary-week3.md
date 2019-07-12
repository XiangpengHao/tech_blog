---
title: "Research Diary Week 3"
date: 2019-07-12T12:08:58-07:00
draft: false 
---

### July 12th

There's a very famous research pattern in the system group, people do experiment-oriented research.

I personally don't like this way of researching, for the following reasons:

1. Mini experiments/benchmarks have very limited insights, sometimes they even point to the opposite direction.
The problem with mini benchmark is small factors/optimizations get magnified, unimportant issues become dominant, and true vital things are thus hidden by them. 

2. It's really really difficult to implement a mini benchmark correctly, there're just tons of things you need to consider in order to simulate the real workload. 
Cache miss, numa effect, CPU pipeline, compiler optimization etc, after you take all these things into consideration, your mini benchmark will grow as much complex as your final implementation (if not more). 

3. More importantly, researching (in my mind), is not about calling `perf` and increase the performance by 15% by reducing a cache line access.
Benchmarking will make you short-sighted, you'll always think about progressively improve the performance, rather than thinking about big pictures and big ideas.



