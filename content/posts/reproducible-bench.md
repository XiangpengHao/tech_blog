---
title: "Observable and Reproducible Benchmark in Rust"
date: 2020-12-05T08:12:07+08:00
draft: true
---

### Benchmark

Research benchmarks need to be reproducible and observable. Existing benchmark framework in rust community (such as `libbench` and `criterion`) largely focus on benchmarking small functions.

Research paper tends to have very comprehensive benchmarks and those benchmarks serves two purpose:

1. They're designed to improve system observability, in other words, those benchmark are to ensure that the system performs as predicted.
2. They try to draw certain conclusions and insights, for example, how certain parameters can change system behaviors.

We observe those benchmarks have following characteristics:

1. They tend to run longer than mini-functions, in practice, we see data intensive benchmarks usually take seconds to warmup and run minutes if not hours to finish a single iteration
2. Unlike most mini benchmarks -- where the difference across different run are obvious -- research benchmarks tend to have very comprehensive parameters and there are just enough factors that can significantly change performance. Obvious factors are thread number, cache size, memory consumption etc,  but a lot other important things are largely ignored by people yet they may secretly change performance, such as kernel version, CPU frequency scaling.

Existing benchmark frameworks are not good fits for research data intensive workloads because they are designed for mini functions which are vulnerable to system noises -- thus they require the target function to run hundreds of times to achieve statistical significance. Long-running data intensive workloads are immune to such noises and are not trivial to repeat hundreds of times.

Benchmarks under data intensive research scenarios demands more features than just measuring time: 

1. We need more ergonomic ways to specify benchmark parameters as research paper typically need to discuss various aspects of the system.
2. Reproducibility are one of (if not the most) the important factor of research works. It would be great for benchmark frameworks to automatically capture all the factors (such as commit hash, kernel version, compiler version etc.) that may change the system behaviors. 
3. Time is not the only results reported in the paper, the benchmark framework should allow researchers to automatically collect additional system metrics, such as cache miss/hit rate, page fault count, memory throughput etc. It should also allow easy integration of custom metric systems, for example, it should allow users to specify their own metrics, such as memory allocation layout for an allocator.
4. The benchmark results should be readable and easy to parse.



### Metric system

Metrics are used to describe the system behaviors. There are two types of metrics: system predefined events, user defined events. An ideal metric system should be able to support both.

Collecting metrics comes with costs, a good metric system should:

1. Turn on and off easily
2. Should never contend in multi-thread scenarios. This means that: (a) its performance should be exactly the same in single thread and multi thread, (b) 



The scientific community thus in need of a new 