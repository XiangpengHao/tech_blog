---
title: "Research Diary Week2"
date: 2019-07-02T22:08:58-07:00
draft: false 
---

July 4th
My series for NUMA vs Re-scheduing will probably stop at part 1, as there're some mysterious results that none of our team can figure out.

The mini benchmark is hugely coupled with too many different factors, like memory/cache/cpu pipeline/compiler optimization/cross socket cache coherence policy etc.
It's difficult and not always sensible to separate these things, say, if a design allows the compilers to perform more optimization, it's technically a good design, even though the logic looks the same.
I've spent days to explain the benchmark results and only to find these results are not general enough, they typically only apply to certain workload, and thus not that insightful to guide future research.  

Anyway, the final take away/decision is, re-scheduling generally has higher overhead than simple cross socket memory access, only when NUMA hit reaches about 300, re-scheduling might be profitable.



July 3rd

Nothing today.


July 2nd

If you're interested in my previous week, checkout the week 1: https://blog.haoxp.xyz/posts/research-diary/

Nothing special today, time flies as usual, I don't have time to work on my own project, instead dealing with different kinds of other things.

After being onboard, 学弟 will be a great help to my research, hopefully.

Fix some grammar mistake of previous post and prepare for a new day!



