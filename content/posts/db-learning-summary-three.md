---
title: "Db Learning Summary Three"
date: 2019-03-31T11:32:50-07:00
draft: false
---

### Main memory DBMS Concurrency Control

- Not a solved problem, especially in main memory database system. Major overhead: lock manager overhead, pessimistic locking overhead
- Solutions: new locking algorithms, OCC, hybrids.

##### lock manager overhead: VLL

- co-locate locks with records, get rid of lock manager
- assumption: know the read/write in advance

##### pessimistic locking overhead: OCC or OCC hybrids

- assumption: conflicts are rare. assumption not always hold, OCC doesn't work under high contention.
- lock **hot record**: a hybrid -> key question: how to know hot record?
- a counter in each memory page -> false positives? deadlocks?

##### pessimistic locking overhead: multi-versioning

- very widely adopted, reader/writer don't block each other: **SQL Server Hekaton**



### In-Memory Index

##### Skip List

- A linked list, with shortcuts. A b+-tree, start from left most.
- Non-trivial to implement concurrent skip list.

##### Bw-Tree

- A mapping table to translate logical page id to physical address

##### Radix Tree

- Direct access within a node, use sub-key as index.
- Choice of span impacts tree height and space. -> improvement: Adaptive Radix Tree (ART)
- Too complex to do lock-free

### Storage in Main Memory DB

- Traditional: No real database in the storage, only logs, recovery == replay logs -> long recovery time
- Main Memory DB: store database in the storage, generate snapshot of the database -> **checkpointing**
- Checkpointing: non-trivial. Options: 1. stop the world and do checkpoint. 2. incremental and commit changes. 3. on shutdown.
- Wait-free Pingpong vs wait-free zig-zag

### Performance Evaluation

- Evaluation setup: a. client-server b. single-machine
- Bechmarks: a. YCSB michrobenchmarks  b. Standard benchmarks
- Perf

### Column Stores

- Why? Transactions we want many columns but fewer rows. In analytics we want many rows but fewer columns
- -> Column-Oriented Storage
- C-Store, MonetDB

### Scale Out DBMS

- multiple machines, communicate on network
- single-master, multiple-masters -> high avaliablity
- log shipping to different servers
- two phase commit with a coordinator.
- Cloud native DBMS: computation on one node, storage on different nodes. Idea: separate the computation and the storage, better scale. Example: AWS Aurora.