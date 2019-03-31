---
title: "Db Learning Summary Three"
date: 2019-03-31T11:32:50-07:00
draft: true
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