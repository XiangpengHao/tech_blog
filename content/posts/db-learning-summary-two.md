---
title: "Db Learning Summary Two"
date: 2019-02-25T20:24:45-08:00
draft: false
---

Ensure data reaches to storage from buffer pool (When should update write to storage?)

- **Force**: write every change immediately to storage
- **No-Force**: Only write to storage when needed - *desired*

Ensure either all or no changes are persisted (atomic)

- **No-steal**: keep all modification until commit
- **Steal**: allow early write-back before commit - *desired*



Database systems use log to ensure atomicity and durability. A log record consists of values changed it will help the recovery process to recovery the record to a consistent state. Thus the log record must be flushed before commit. Since a transaction may generate multiple log records, there's a log buffer to cache these logs and flush them to the storage before commit.

ARIES in a nutshell: redo committed logs, undo uncommitted logs.

Logging overhead (non-trivial to solve, problem exists there, persistent memory might save the world)

- I/O delays: Since the DBMS enforces flush-before-commit, every commit will wait for the log to be persistent. solution: *a log buffer to group the flush operations*
- Lock Contention: Lock must be released after the log is flushed.
- Scheduling overhead: Waiting for I/O flush will cause the scheduler to deschedule the transaction, introduces more context-switch
- Logging buffer contention: Almost all system use centralized log buffer, all transactions trying to mutate the log buffer. 



B-Tree:

- **Allows Range Scan**, important feature (vs hash table), most used in database systems.
- B+ - Tree vs B - Tree. B+ tree only stores record on leaf node -> normalized key access time.
- **Bulk Loading**. Option1: create a new tree, insert the records one by one *top-down*. option2: sort the record, build the tree from leaf node *bottom-up*.

Skip List:

- Allows range scan. Looks like a B-tree.
- Insertion might need to rearrange the entire list. Randomness is not acceptable in all cases. Too many pointers, too many cache misses. Existing optimization can help though.

Hash Table:

- **No range scan**. Probably the fastest for point queries.
- Hash table don't suffers from data increase or decrease and reorganize the data structure is expensive.
- Ad hoc tricks/optimizations introduced to address the problem (*extensible hashing and linear hashing*). Do not really solves the problems and performance decreases