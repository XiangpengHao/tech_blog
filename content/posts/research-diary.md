---
title: "Research Diary"
date: 2019-06-26T19:26:19-07:00
draft: false
---

听说写 research diary 可以有种种好处（虽然并没有人能坚持下来），但我的朋友们突然开始写 research diary，如果我不写就输了，这是主要 motivation.

先给这个 diary 定下以流水帐为主，娱乐为辅的基调。如果偶尔能有点学术的光芒，一定是你想多了。原则上我应该用 English 写，但 English 只适合用来陈述事实，不适合用来表达情感，有违我的初衷。（但我的朋友们用的是 English 所以我也不能写太多中文）


### June 26th

My new data structure works pretty well on paper, I send my brief report to tz, no response from him. He is busy with the CMPT 454 course. 

I fixed a few bugs in my new tree, then feels sleepy so took a short nap. I have quite slow progress these days, partly because I got too much other things to do, partly because I'm hitting the most dangerous zone of this project.

There're two trends in in-memory index data structure design, the first is to design super efficient in-memory indexs that don't care disk/memory/cpu usage, their target is to achieve as much throughput as they can, which means to make full use of all hardware resources. The second is to design in-memory index that works on *persistent memory*.

With these two trends, there're increasing number of papers discussing how to achieve these goals. And I joined them.

Among all the papers I read, only three of them have real insights. I like them not (only) because their performance beat the state-of-the-art in-memory index, they also bring new ideas that might guide the future research.

The first paper is `The Adaptive Radix Tree: ARTful Indexing for Main-Memory`, aka `ART`, `ART` is the frist tree that outperforms the hash table in terms of point-query. 
Their main contribution, path compression/lazy expansion/memory saving, are less important.
The real value comes from the experiments, they are the frist tree-based index that beat hash-table, people want to find the real reason, and that's the value of this paper.

The second paper is `Cache craftiness for fast multicore key-value storage`, aka `Masstree`.
`Masstree` at first look only solves the problem of variable-length keys (and that's what they claimed). 
But they are the first paper trying to split a whole b+ tree to serveral chunks. By doing this, they 1. have fixed-length key in each node 2. implicitly store the keys into search path 3. save memory bandwidth when searching.
Their work is solid, remarkable, and revolutionary. 

The third paper is `FPTree: A Hybrid SCM-DRAM Persistent and Concurrent B-Tree for Storage Class Memory`, aka `FPTree`. This paper is not about insightful design, it's more about decision making. 
The authors did not explain their motivation of making the descision, but it's enough to know how these choices impacted the performance. I like their solid and skillful tricks that carries profitable optimizations.