---
title: "Paper Review: Flash Memory"
date: 2020-02-03T12:42:49-08:00
draft: false 
---

Both papers are not interesting to me, it's not that flash memory are uninteresting, 
but these techniques are too far away from my current research, i.e. I can not think critically on their approaches, they are more like good-to-know papers.


### Page-Differential Logging: An Efficient and DBMS-Independent Approach for Storing Data into Flash Memory
This paper tried to solve a old problem: asymmetric read/write time of data storage, 
in the context of flash memory, this paper also helps to improve the wear-level and thus increase the longevity of the storage device.
The main contribution of this paper is to propose a new data-access pattern tailored for the flash memory, this new access pattern combined the existing page-based and log-based techniques.

The good part of this paper is that the proposed access pattern is transparent to the upper-level applications, 
thus any application using flash memory should benefit from this new techniques.
From this point of view, this paper should be more widespread for its generality, thus I quite suspect that some of their claims are limited to the database system access pattern.


### Hyder – A Transactional Record Manager for Shared Flash
This paper yet again comes from a very industrial large project, it's a record manager across many flash devices.
The database is a multi-version binary tree, each server has a snapshot of the database.
Whenever a transaction finished on a node, the node will propagate the changes to the centralized log manager, which will determine whether to abort or commit the change. In other words, this approach is a variant of OCC.
The log manager, called meld, is the centralized single-threaded system that execute the changes.

So one obvious bottleneck is their single-threaded meld can limit the scalability of the whole system, especially when there are a lot more working servers.
The authors, however, can still argue that it's impossible for a system to go infinitely large scale, rather, it is to which extend the system can scale that matters.
For a traditional system, we need to partition the data at a very early stage, under such context, the Hyder is a step towards a non-partitioned system.


