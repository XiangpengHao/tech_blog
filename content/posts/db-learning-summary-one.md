---
title: "Database System Learning Summary One"
date: 2019-02-10T15:42:25-08:00
draft: false 
---



- **NUMA.** A server may have multiple processors (sockets), each socket may have multiple physical cores, each core may carry multiple threads (hyper-threads). Memory is partitioned on multi-socket machines, where each socket has its own local memory but it can access (remote) memory from other sockets. Accessing remote memory is slower (due to latency?) than accessing local memory, this is called NUMA effect.
- **Memory Hierarchy.** L1 cache reference: *0.5 ns*, L2 cache reference: *7 ns*, Main memory reference: *50 ns*. *A L1 cache miss has 100 times penalty*. Persistent Memory reference *100 ns*. NAND SSD reference *10 us*. [reference](https://gist.github.com/jboner/2841832), [reference](https://docs.pmem.io/getting-started-guide/introduction), 2018.
- **Persistent Memory.** DRAM + Battery or ~~Intel 3D XPoint, will launch next month~~. Similar speed to state-of-the-art NVMe SDD, significantly better latency, thus *better random access* and *byte-addressable*.
- **Five-minute Rule.** Pages referenced every 5 minutes (or less) should be kept in memory (rather than HDD), in 1987. 30 years later (2017), about 5 hours (RAM-HDD) or 7 min (RAM-SATA SSD) or 41 s (RAM-NVMe SSD). [reference](http://rajaappuswamy.com/uploads/8/9/4/5/89452844/5minute-rule.pdf).
- **Serializable.** The result of two concurrent tasks is same to their (one of the) serial execution result. Serializability is sufficient but not necessary to correct results. High overhead.
- **Conflict Serializability.** If two actions conflict if they operate on same data record and at least of them is a write. A schedule can be transformed to a serial schedule is called conflict serializability.
- **2 Phrase Locking (2PL).** Phase 1: acquire all the locks (cannot release any lock during this phase). Phase 2: release lock (cannot acquire any lock). Guarantees serializability, needs a lock manager to prevent deadlock, which is the bottleneck. *We try to go lock-free*.
- **Optimistic Concurrency Control (OCC).** Key Assumption: conflicts are rare (low contention). No locks, just keep retrying, similar to [CAS](https://en.wikipedia.org/wiki/Compare-and-swap). Drawbacks: repeatedly failure on high contention work. 
- **Multi-Version Concurrent Control (MVCC)**. Have multiple versions of a single record. Link from new to old versions, update always add a new version (*no overwrite*), use time stamp to pick version. ANSI requirements: Repeatable Reads + no phantom. -> snapshot isolation. Snapshot isolation however is not always serializable so there may have anomalies -> because read and write may happen concurrently.
- **MVCC Serializability.** To protect the read. 
  - Fix the DBMS: 2PL based MVCC (slow). OCC based MVCC (false positive).
    - **Serializable Snapshot Isolation (SSI)**: Detecting dangerous edge cycles in dependency graph. If a transaction has incoming conflict edge and an outcoming conflict edge, a cycle might happen, must abort (false positive). Detect cycles is non-trivial and costly, want simple workaround but lead to false positive.
    - **Serial Safety Net (SSN)**: efficiently detect cycle dependencies. Abort if latest predecessor commits later than earliest successor.
  - Teach the developer. Adhoc, not always work, performance depends on the implementation.