---
title: "Research Diary"
date: 2019-06-26T19:26:19-07:00
draft: false
---

听说写 research diary 可以有种种好处（虽然并没有人能坚持下来），但我的朋友们突然开始写 research diary，如果我不写就输了，这是主要 motivation.

先给这个 diary 定下以流水帐为主，娱乐为辅的基调。如果偶尔能有点学术的光芒，一定是你想多了。原则上我应该用 English 写，但 English 只适合用来陈述事实，不适合用来表达情感，有违我的初衷。（但我的朋友们用的是 English 所以我也不能写太多中文）

### June 30th
Major: bg's birthday; Minor: research obstacles.

I tried my new ideas on numa-aware index, the prototype doesn't show expected numbers.
So all my work today is to design mini benchmarks to figure out why the experiment results don't match with my expectation.

Programming in numa sockets, I take the following factors into consideration:

1. Cache hit, did we really issue a memory load, or just used the cached values. So to simulate the real-world workload, I evicted the whole last level cache between tests.

2. Cost of re-scheduling. How costly it is for on-fly context switch. Cost of rescheduling is the most important criteria to achieve beneficial numa optimization, as it's a trade-off between context switch and remote memory access.

3. CPU pipelines, with very regular workload, modern CPU is capable of maintaining a quite low branch prediction miss rate, thus can hide the memory access latency due to predictable pre-fetch.
While in the real-world cases, the workload tends to be very irregular thus less predictable. Trivial tests might not be enough to demonstrate the numa-effect.

In my today's experiments, I only take the first two into account, and for remote memory access, the performance only drops ~12%, while the expected number is 50%.

I might need to design a complex work load and try again tomorrow.

### June 29th
Research is about time management. 
I feel less productive and less efficient these days, if I remember correctly, it begins from the day I joined Kevel's project.

I obviously under-estimated the over-head of working on multiple projects at the same time, especially when working on more than four parts:
1. I have my main stream research topic 
2. A project just started with another AP in our lab 
3. A project lead by a visiting PhD student, and he needs my effort the catch the FAST 2019 deadline 
4. My old previous IEEE TIP paper. 
And I'll need to help with tz's course project.

That's definitely too much for me, in the terminology of Operating System, we call this phenomenon [`thrashing`](https://en.wikipedia.org/wiki/Thrashing_(computer_science)).

Nevertheless, it makes me realized time managing is vital to successful research, and I should be brave to say no. 
What's more, I should probably learn to use resources around me to boost my research, instead of taking everything on my shoulder.

Looking forward to see a more organized tomorrow :)


### June 28th
More debugging today, so nothing special on my project. 

The biggest thing is a 学弟 joined us, he took the CMPT 454 course this term, and is very active on the project milestones. So I tentatively asked if he would like to join us and dig more into the area. And he said yes.

Concurrently Working on three projects (four if including Brian's paper) is too much for me, the cost of context switch between different projects is too high to be sustainable.
学弟 has sufficient knowledge on both high performance computing and c++ programming language, looking forward to work with him!

One last thing is swimming, better than last time, I feel just comfortable. I enjoy the relaxing time after swimming. And the 烧烤 is nice as well! Nice day! 


### June 27th
Today is nothing but debugging. Writing lock-free multi-thread application is extremely difficult, as it takes unbearably time and effort to debug. 
There's no tools that can help, there's no rules/hints that can guide you to implement ideas correctly. The best debugger is your brain, said tz.

Apart from this, I got an update from Brian, he really has a lot of things to do, and time is very limited, as he'll start a new journey in California (FB). If he can finish the writing soon, I'll be able to submit my third paper this year :)

Last thing is TA office hour, it's now a place for me to practice speaking and listening, and most importantly, how to express ideas. 
Nevertheless, TA session is very boring and students keeps asking questions that make you feel helpless -- you can't explain what's scheduling to students who don't understand what is thread.  


### June 25th
Meeting all day, did almost nothing. The only thing worth talking is the proof in the `FPTree` paper. 
I almost had the same solution as `FPTree`, I talked to tz, he told me someone has already implemented the idea :(

Ideas are simple, proofs are not, especially how they converted a complex design into several small parts. I appreciate their profound statistic skills. Here I try to reproduce their proof based on my understanding.

For any searching $K$, its expected number of fingerprint collision is $E(K)$, it's given by the sum of all occurrence times corresponding possibility.
$$E(K)=\sum_{i=1}^{m}i  P(K=i)$$

$P(K=i)$ is the possibility of $K$ collide exactly $i$ times, given the fact there're at least 1 occurrence.

With that said, we can decompose the $P(K=i)$ into two sub-events:

A: the search fingerprint occurs exactly i times

B: the search fingerprint occurs at least once.

The $P(K=i)$ can be expressed as $P(K=i)=P(A|B)=\frac{P(A \cap B)}{P(B)}$
$$P(K=i)=\frac{(\frac{1}{n})^i(1-\frac{1}{n})^{m-i}\binom{m}{i}}{1-(1-\frac{1}{n})^m}$$

I like how they decompose the problem, insightful.

### June 26th

My new data structure works pretty well on paper, I send my brief report to tz, no response from him. He is busy with the CMPT 454 course. 

I fixed a few bugs in my new tree, then feels sleepy so took a short nap. I have quite slow progress these days, partly because I got too much other things to do, partly because I'm hitting the most dangerous zone of this project.

There're two trends in in-memory index data structure design, the first is to design super efficient in-memory indexes that don't care disk/memory/cpu usage, their target is to achieve as much throughput as they can, which means to make full use of all hardware resources. The second is to design in-memory index that works on *persistent memory*.

With these two trends, there're increasing number of papers discussing how to achieve these goals. And I joined them.

Among all the papers I read, only three of them have real insights. I like them not (only) because their performance beat the state-of-the-art in-memory index, they also bring new ideas that might guide the future research.

The first paper is `The Adaptive Radix Tree: ARTful Indexing for Main-Memory`, aka `ART`, `ART` is the first tree that outperforms the hash table in terms of point-query. 
Their main contribution, path compression/lazy expansion/memory saving, are less important.
The real value comes from the experiments, they are the first tree-based index that beat hash-table, people want to find the real reason, and that's the value of this paper.

The second paper is `Cache craftiness for fast multicore key-value storage`, aka `Masstree`.
`Masstree` at first look only solves the problem of variable-length keys (and that's what they claimed). 
But they are the first paper trying to split a whole b+ tree to several chunks. By doing this, they 1. have fixed-length key in each node 2. implicitly store the keys into search path 3. save memory bandwidth when searching.
Their work is solid, remarkable, and revolutionary. 

The third paper is `FPTree: A Hybrid SCM-DRAM Persistent and Concurrent B-Tree for Storage Class Memory`, aka `FPTree`. This paper is not about insightful design, it's more about decision making. 
The authors did not explain their motivation of making the decision, but it's enough to know how these choices impacted the performance. I like their solid and skillful tricks that carries profitable optimizations.


<script type="text/x-mathjax-config">
MathJax.Hub.Config({
  tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}
});
</script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

