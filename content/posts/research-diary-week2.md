---
title: "Research Diary Week2"
date: 2019-07-02T22:08:58-07:00
draft: false 
---

### July 10th
Got two things to talk.

When reading the news and looking at what's happening around the world, a lab in Stanford catch my eyes.
The `future data systems`: http://futuredata.stanford.edu/

In their homepage, they said:

>We are interested in two types of systems:

> 1. Systems that are at least an order of magnitude better than the competition ("10x systems").
> 
> 2. Systems that are the first of their kind ("0 to 1 systems").
> 
> 10x systems are almost always powered by smart algorithms and/or clever use (or disuse) of hardware. 0 to 1 systems are enabled by creativity, audacity, and raw ambition. We build both.

I was really impressed by their idealism goals, and (kind of) shame of what I'm doing.

My life is full of people talking about papers/publications/grad schools, they judge people by which conference their paper went to (instead of what contributions that paper made), or which grad school/prof they applied (instead of what their own goals and plans).

I admit they might eventually be the winners/somebody, but I just don't like them being [exquisite egoists](https://laitman.com/2013/08/exquisite-egoists/).

I imagined the ultimate honor of my whole life, would be a scientist who devote all his life to improving human civilization, like what [Valery Legasov](https://en.wikipedia.org/wiki/Valery_Legasov) did for the Soviet Union.   

The other thing I would like to mention is (let's save for tomorrow) 


### July 9th
Meeting and TA all the day, nothing special.

### July 8th

Nothing special today, interesting part of researching has passed, the remaining are mostly boring and tedious.

What keeps me continuing is ... (tell me if you know)



### July 7th

Context: modern in-memory b+ tree variant.

#### Why CoW?

Internal nodes need to maintain sorted order, so that search don't need to load the whole node

Any sorting algorithm will require more than 8-byte write, which is not feasible in the persistent memory/lock-free concurrency era.

So the modern b+ tree structures used copy-on-write strategy to address the problem.
The basic assumption of CoW is unlimited memory bandwidth, this assumption, however, is not always satisfied (as shown in our latest paper), and it might incur extra overhead (e.g. pressure on memory allocator).



#### How do we design mutable internal node?

the idea is to have smaller keys -> more keys in a cache line -> CPU time remains the same, but IO time greatly reduced.
1. Similar CPU time: we still need to compare every keys in a node
2. Smaller IO/data time: less cache line to be loaded 

We can use SIMD instructions to reduce the CPU time.


### July 6th

Another Saturday arrives, time flies and I realized the nature of research is probably being slow.

You'll need to think, writing code doesn't mean you're doing something, and writing nothing doesn't mean you contributed nothing.

Some other thoughts: is human being capable of handling lock-free concurrency data structures?

The answer (for now) is NO. We don't have enough tools for correctness proofing and debugging.

Both tasks are hugely rely on a small group of people, their proof can have holes, their implementation can be incorrect, and nobody can find it util the system explodes.

We (the society) desperately need tools that can build reliable infrastructures, that's why I show huge respect to the rust community, they're not perfect, but a step forward to the ultimate goal.  


### July 5th

Nothing today. Friday, have a nice tennis with bg.

OverWatch ranked 150+ SR, nice huge plays.

### July 4th

My series for NUMA vs Re-scheduing will probably stop at part 1, as there're some mysterious results that none of our team can figure out.

The mini benchmark is hugely coupled with too many different factors, like memory/cache/cpu pipeline/compiler optimization/cross socket cache coherence policy etc.
It's difficult and not always sensible to separate these things, say, if a design allows the compilers to perform more optimization, it's technically a good design, even though the logic looks the same.
I've spent days to explain the benchmark results and only to find these results are not general enough, they typically only apply to certain workload, and thus not that insightful to guide future research.  

Anyway, the final take away/decision is, re-scheduling generally has higher overhead than simple cross socket memory access, only when NUMA hit reaches about 300, re-scheduling might be profitable.



### July 3rd

Nothing today.


### July 2nd

If you're interested in my previous week, checkout the week 1: https://blog.haoxp.xyz/posts/research-diary/

Nothing special today, time flies as usual, I don't have time to work on my own project, instead dealing with different kinds of other things.

After being onboard, 学弟 will be a great help to my research, hopefully.

Fix some grammar mistake of previous post and prepare for a new day!



