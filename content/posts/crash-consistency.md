---
title: "Concurrent consistency is NOT crash consistency!"
date: 2019-10-29T16:22:37-07:00
draft: false
---
And converting a concurrent-consistent data structure to a crash-consistent one needs non-trivial efforts.  

This is a paper review of RECIPE[^1].

Update 10-29: 
There's a limitation section in their [repo](https://github.com/utsaslab/RECIPE#limitations), but these things are not mentioned in the paper.

### RECIPE assumes:

> Recipe also assumes that unreachable PM objects will be **garbage collected**, as a failed update operation may result in an allocated but unreachable object. ($4.2)

The assumption is non-trivial, in fact,
it's so difficult that nobody knows how to **efficiently** prevent persistent memory leaks.

What's more, none of their evaluations actually implemented **garbage collection**, and none of them are memory safe.
By not having complex memory management in their code, they have superior performance advantages over other data structures. 



### RECIPE claims:

![](/img/recipe_cond_1.png)

RECIPE claims the following code is correct:

```c++
flush();
mfence();
CAS(addr, old_v, new_v);
flush()
mfence();
```
The claim is wrong, and code above is incorrect, 
because other threads may read the `new_v` before it is flushed to memory,
in other words, other threads `read uncommitted`. 
I will explain a bit more since it's very subtle:
```c++
/* Thread 0 */              |   /* Thread 1 */
flush();                    |
mfence();                   |
CAS(addr, old_v, new_v);    |
                            |   v = load(addr);
                            |   if v:
                            |       push_nuclear_button();
                            |
            /******** power failure ********/ 

flush()
mfence();
```

The thread 1 will read the `new_v` before the `addr` is properly persisted, 
but on recovery, the `addr` will still have `old_v`. 
**Inconsistent!**

This is called `read uncommitted`[^2], the lowest isolation level in concurrency control, 
and all serious database systems[^3] requires at least `read committed`, one layer higher than `read uncommitted`.

The biggest issue, however, is not to have a `read uncommitted` data structure, 
but to **downgrade** the isolation level when performing the conversion,
that is, all the data structures before conversion promise at least `read committed`. 

Again, by not staying at the same isolation level, RECIPE has huge advantages over its competitors.

### Conclusion

RECIPE claimed it's **simple** to convert a concurrent-consistent data structure to a crash-consistent data structure, but as I showed above:

1. Persistent Memory management is non-trivial.
3. Their conversion downgrades the isolation level.
2. `read uncommitted` is not practical. 

Nevertheless, I'm glad to see someone materialized the intuition: 
**concurrent-consistency is somehow related to crash-consistency.**

It's just not that simple. 

I'm also afraid the performance numbers reported in their paper will set an unrealistic bar for future research, 
and discourage those well rounded practical systems, especially when the paper is published in SOSP.


[^1]: RECIPE : Converting Concurrent DRAM Indexes to Persistent-Memory Indexes
[^2]: [Data Concurrency and Consistency](https://docs.oracle.com/cd/B28359_01/server.111/b28318/consist.htm#CNCPT020)
[^3]: [PostgreSQL](https://www.postgresql.org/docs/9.1/transaction-iso.html), [Oracle](https://docs.oracle.com/cd/B28359_01/server.111/b28318/consist.htm#CNCPT221), [SQLServer](https://docs.microsoft.com/en-us/sql/t-sql/statements/set-transaction-isolation-level-transact-sql?view=sql-server-ver15)
