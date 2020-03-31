---
title: "Paper Review: tricky DB"
date: 2020-03-30T18:48:23-07:00
draft: false 
---

This week we will discuss about system tools for database systems. 
The first paper talks about the potential applications when remapping the virtual and physical memory is possible,
and I'll present the topics about coroutine, which deserves a whole separate post (todo).

### RUMA has it: Rewired User-space Memory Access is Possible!
We can divide the paper into two parts: the first part shows how to do user space remapping, the second part shows the potential usages.

When I first read the paper, I can't believe remapping the memory is possible in user space, 
and I was astonished to know the authors used `MAP_FIXED` to achieve this goal. 
I've been working on memory mapped files for quite a while but have never thought of this clever usage.

Nevertheless, the immediate question pop out of my mind is that how can we use it to improve performance?
It must be tricky because otherwise the kernel will support the feature.
But I can't come up with any applications without continue reading the paper.
The main selling point is to reduce memory migration when changing the memory structure is required. 
This is not a strong argument, but it works, and good to know.



