---
title: "Transaction Isolation levels"
date: 2020-07-01T17:37:02-07:00
draft: false 
---

Summarize "A Critique of ANSI SQL Isolation Levels", which I believe is one of the most important paper in the database research.

## ANSI SQL Isolation Level

### Phenomena
**Dirty read**. 
A dirty read is the situation when a transaction reads a data that has not yet been committed.

**Non repeatable read**.
Non repeatable read occurs when a transaction reads the same row twice and get a different value each time.

**Phantom read**.
Phantom read occurs when two same queries are executed within a transaction, but the rows retrieved by the two are different.

*Remark:* the difference between non-repeatable read and phantom read stems from that non-repeatable read test on a single value, 
while the phantom read check the whole predicate (a set of rows).

### Isolation levels
**Read uncommitted**.
Read uncommitted is the lowest isolation level.
In this level, a transaction may read not yet committed changes from other transactions, thereby allow dirty reads.

**Read committed**.
This isolation level guarantees that any data read is committed at the moment it is read.
The transaction holds a r/w lock on the current row.

**Repeatable read**.
The transaction holds locks on all rows it read/write, thus avoids non-repeatable read.

**Serializable**.
An execution of operations in which concurrently executing transactions appear to be serially executing.


| Isolation Level   | Dirty Read |      Non Repeatable Read |  Phantom Read |
|----------|:-------------:|------:| ------:|
| Read uncommitted |  Yes | Yes | Yes |
| Read committed |  No | Yes | Yes |
| Repeatable read |    No |   No | Yes |
| Serializable | No |    No | No |


## ANSI SQL Isolation has problems

### The three ANSI phenomena are ambiguous
>Only the more mathematical definitions in terms of histories and dependency graph or locking have stood the test of time.

English language definition of **dirty read**:
Transaction T1 modifies a data item.
Another transaction T2 then reads that data before T1 perform a *commit* or *roll back*. 
The English definition has two interpretations:

- w1\[x\] ... r2\[x\] ... (a1 and c2 in either order)
- w1\[x\] ... r2\[x\] ... ((c1 or a1) and (c2 or a2) in any order)

The border interpretation can exclude more histories.
This also apply to *non-repeatable read* and *phantom read*.

For all three phenomenons boarder (stricter) interpretations are required for ANSI SQL isolation level.

### Even the broadest interpretations do not exclude anomalous behavior

**Dirty write**

- w1\[x\] ... w2\[x\] ... ((c1 or a1) and (c2 or a2) in any order)

ANSI SQL isolation should be modified to require P0 (dirty write) for all isolation levels.

**Phantom read** must be restated so that it prohibits any write satisfying the predicate once the predicate has been read -- the write could be insert, update, or delete.

### ANSI phenomena do not distinguish among some more isolation levels

#### Cursor Stability

**P4 (Lost Update)**
- r1\[x\] ... w2\[x\] ... w1\[x\] ... c1  (lost update)

Anomaly P4 is useful in distinguishing isolation levels intermediate in strength between *read committed* and *repeatable read*.

Cursor stability is widely implemented by SQL systems to prevent lost updates for rows read via a cursor.

#### Snapshot Isolation
Each transaction reads data from a snapshot of the (committed) data as of the time the transaction started.
A transaction running in *Snapshot Isolation* is never blocked attempting a read as long as the snapshot data from its start timestamp can be maintained.

**Read skew**:
Suppose transaction T1 reads x, and a second transaction T2 updates x and y to new values and commits.
If now T1 reads y, it may see an inconsistent state, and therefore produce an inconsistent state as output.

**Write skew**:
Suppose transaction T1 reads x and y, which are consistent with *C()*,
and then a T2 reads x and y, writes x, and commits.
Then T1 writes y.
If there's a constraint between x and y, it might be violated.

Remark: fuzzy reads is a degenerate form of *read skew* where x=y.

Read skew is possible under *Read Committed* but not under snapshot isolation,
therefore *Read Committed* << *Snapshot Isolation*.

Snapshot isolation cannot experience the A3 anomaly (Phantom Read).
A transaction rereading a predicate after an update by another will always see the same old set of data items.
Snapshot isolation prohibit histories with anomaly A3, but allow write skew, while *Repeatable read* does the opposite.
Therefore, *Repeatable Read* >><< *Snapshot Isolation*.  

Snapshot isolation has no phantoms. 
Each transaction never sees the update of concurrent transactions.
*Anomaly Serializable* << *Snapshot Isolation*.

## Summarize

|Isolation Level      |Dirty Write|Dirty Read|Cursor Lost Update|Lost Update|Non Repeatable Read|Phantom  |Read Skew|Write Skew|
|---------------------|-----------|----------|------------------|-----------|-------------------|---------|---------|----------|
|Read Uncommitted     |N          |Y         |Y                 |Y          |Y                  |Y        |Y        |Y         |
|Read Committed       |N          |N         |Y                 |Y          |Y                  |Y        |Y        |Y         |
|Cursor Stability     |N          |N         |N                 |Sometimes  |Sometimes          |Y        |Y        |Sometimes |
|Repeatable Read      |N          |N         |N                 |N          |N                  |Y        |N        |N         |
|Snapshot             |N          |N         |N                 |N          |N                  |Sometimes|N        |Y         |
|ANSI SQL Serializable|N          |N         |N                 |N          |N                  |N        |N        |N         |

