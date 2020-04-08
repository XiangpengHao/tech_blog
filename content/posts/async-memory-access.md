---
title: "A view of async memory access in rust"
date: 2020-04-01T14:51:35-07:00
draft: true 
---

## Section 1: Background
We have been using asyncio for years to hide the IO latency.
Major high-level programming languages -- except C++, which is expect to have coroutine in C++20 -- have proper support for both language syntax (programmability) and user space scheduling (functionality).

It's common believe that coroutine has much smaller overhead than the operating system scheduler, but we don't yet understand the potential of this "smaller overhead".
The reasons are two folds. First, those high level programming languages (Python, Java, Go) don't really care about "system programming", 
where memory layout and cache friendliness is vital. 
They tend to implement the coroutine with costly stack frames, and in such cases, the implementation overhead varies.
Second, none of the major system programming languages -- especially those with zero-overhead claim languages -- has proper support for coroutine.
Without the joint efforts of language design and compiler optimization, we won't have the chance to push the overhead limit.

Rust is the first challenger.
After years of debating and improving, Rust finally launched its initial stable support for async/await (in Nov 2019).
Rust is also the first programming language that claims "zero-overhead abstraction" on the coroutine support. 
For those who are not familiar with the term "zero-overhead abstraction", here's a definition from the creator of C++:

> What you don't use, you don't pay for (in time or space) and further: What you do use, you couldn't hand code any better.

Previous researches[^1] have shown the vendor-specific coroutine implementations in C++ have the overhead less than a memory access,
in other words, we might be able to use coroutine to hide the memory stall on cache miss.

In this post, I'll explore how to use Rust to perform async memory access in section 2, 
then I'll present the design and implementation of a minimal scheduler in section 3,
and lastly I'll benchmark the system and perform a micro-architecture analysis to measure the overhead of rust task scheduling. 

## Section 2: Async Memory Access
Recall that async IO scheduling requires tasks to voluntarily give up the control when the IO operation begins, 
and notify the scheduler when the IO operation finishes. 
Once received the notification from the task, the scheduler will add the task to the ready queue so it will have chances to continue its work.

Async memory access imitates this pattern: when a task encountering a cache miss, it voluntarily give up the control.
The difference is that instead of removing it from the task queue and waiting for the ready signal, the scheduler will immediately append the task to the end of the ready queue.
This is because we don't have a mechanism for the task to notify the scheduler.

IO operations often have clear boundaries on IO begin and IO ends.
For example, the programmer knows when the networking IO starts so it can notify the scheduler timely,
the networking device/operating system offers a mechanism to wake the scheduler when the networking IO is finished,
so that the scheduler can add the task back to the ready queue.

Async memory access, unfortunately, don't have this property.
Our current architecture lacks a mechanism to indicate whether a memory address exists in the cache. 
This means that programmers need to **guess** when to switch out and when to switch back.
Some papers[^2] suggest future hardware to support this feature, but it's unlikely to happen in the near future.

A bad guess of cache existence can be costly: task switch can be profitable only when memory is not present in cache, 
otherwise it's pure overhead. 
However, unlike the hardware pre-fetching where low level implementation has limited view of software behaviors,
user space async memory access can benefit from high level semantics.
For example, if the programmer is to access the leaf node of a large b+ tree, 
the memory access will very likely cause a cache miss, and vice versa.

## Section 3: Implementation (in Rust)
### The workload
The workload should cover two aspects: (1) it should be hard to predict in hardware (2) it should be easy to parallel.
The easiest workload I can come up with are **multiple linked lists**, where each job individually traverse one linked list.

To avoid cache line ping-pong and make sure every memory access is a cache miss, we pad each element to a cache line width.

```rust
#[repr(C)]
#[derive(Debug, Copy, Clone)]
pub struct Cell {
    next_index: u64,
    _padding: [u64; 7],
}

impl Cell {
    pub fn new(next_idx: u64) -> Self {
        Cell {
            next_index: next_idx,
            _padding: [0; 7],
        }
    }
    pub fn set(&mut self, value: u64) {
        self.next_index = value;
    }
    pub fn get(&self) -> u64 {
        self.next_index
    }
}
```

Linked list nodes are often allocated from the heap, but we instead use an large `Cell` array to suppress the issues from the allocator. 
We then initialize the array to a linked list by inserting random shuffled values.
![](/async/async-workload.png)

```rust
pub struct ArrayList {
    pub list: Vec<Cell>,
}

impl ArrayList {
    pub fn new(array_size: usize) -> Self {
        let mut workload_list = ArrayList {
            list: vec![Cell::new(0); array_size],
        };
        let mut temp_values: Vec<u64> = Vec::with_capacity(array_size - 1);
        for i in 1..array_size {
            temp_values.push(i as u64);
        }
        temp_values.shuffle(&mut thread_rng());

        let mut pre_idx = 0;
        for elem in temp_values.iter() {
            workload_list.list[pre_idx].set(*elem);
            pre_idx = *elem as usize;
        }
        workload_list
    }
}
```


### Baseline
The base line implementation is quite simple: the reading thread traverse the linked lists.
To verify the correctness, we ask the each job to accumulate all the values it reads, 
and we expect the total sum to match with the precomputed value.  

The following code implements the `Traveller` trait -- a common interface for various such implementations.
The code is quite simple and self-explanatory, yet it is the **best possible implementation** (without awkward code construction) for single thread executions.
Also note that memory pre-fetching doesn't work here due to the irregular access pattern. 

```rust
pub struct SimpleTraversal;

impl<'a> Traveller<'a> for SimpleTraversal {
    fn traverse(&mut self, workloads: &[ArrayList; GROUP_SIZE]) -> u64 {
        let mut sum: u64 = 0;
        for workload in workloads.iter() {
            let mut pre_idx = 0;
            for _i in 0..workload.list.len() {
                let value = workload.list[pre_idx].get();
                pre_idx = value as usize;
                sum += value;
            }
        }
        sum
    }

    fn get_name(&self) -> &'static str {
        "SimpleTraversal"
    }

    fn setup(&mut self) {}
}
```

### Async memory access
Async implementation requires a bit more setup: (1) we need an executor (scheduler) which holds and executes the tasks,
(2) we need to fill the executor will async state machines. 
The following code basically does those two things.

```rust
pub struct AsyncTraversal<'a> {
    executor: executor::Executor<'a>,
}

impl<'a> Traveller<'a> for AsyncTraversal<'a> {
    fn setup(&mut self) {}

    fn traverse(&mut self, workloads: &'a [ArrayList; GROUP_SIZE]) -> u64 {
        for workload in workloads.iter() {
            self.executor
                .spawn(Task::new(AsyncTraversal::traverse_one(workload)));
        }
        self.executor.run_ready_task()
    }

    fn get_name(&self) -> &'static str {
        "AsyncTraversal"
    }
}
```

The `traverse_one` function is very similar to the synchronous version.
We, however, have two extra components: the code prefetching (line 7-12), 
and immediately task switch (line 13).
We use the x86_64 instruction `_MM_HINT` for memory prefetching, where `T0` means fetching to L1 cache.
We will discuss the `MemoryAccessFuture` in the later sections, 
it basically tells the scheduler that the current task should be scheduled out. 

{{< highlight rust "linenos=table,hl_lines=7-13" >}}
impl<'a> AsyncTraversal<'a> {
    async fn traverse_one(workload: &ArrayList) -> u64 {
        let mut pre_idx: usize = 0;
        let mut sum: u64 = 0;

        for _i in 0..workload.list.len() {
            unsafe {
                _mm_prefetch(
                    &workload.list[pre_idx] as *const Cell as *const i8,
                    _MM_HINT_T0,
                );
            }
            MemoryAccessFuture::new().await;
            let value = workload.list[pre_idx].get();
            pre_idx = value as usize;
            sum += value;
        }
        sum
    }
}
{{< / highlight >}}

### Scheduler (executor)
The scheduler is the most interesting part.
Unlike most other programming languages, where the language committee specifies an official runtime 
and the programmers have no ways to change it.
The Rust decouples the async state machines with the schedulers, and allows programmers to chose whichever executors that fits best in their use case.
This flexibility is extremely important to us, as we want to build our own lightweight executor that is tailored for the async memory access.

The executor design is simple: it has four tasks slots, the execution cursor rotates around these tasks until all the tasks conclude.
![](/async/async-executor.png)

```rust
pub struct Executor<'a> {
    task_queue: [Option<Task<'a>>; EXECUTOR_QUEUE_SIZE],
}

impl<'a> Executor<'a> {
    pub fn spawn(&mut self, task: Task<'a>) {
        for i in 0..EXECUTOR_QUEUE_SIZE {
            if self.task_queue[i].is_none() {
                self.task_queue[i] = Some(task);
                return;
            }
        }
        panic!("max executor queue reached!");
    }
}
```

The executor will `poll` the tasks and check if they are ready to continue,
we thus need to design a special task for async memory access.
The idea is simple: return `ready` after a small period.
Constructing a timer can be costly, we instead use a heuristic based approach:
only when the executor asked us for a second time, we return `ready`, otherwise return `pending`.
In rust code, this is as simple as:

```rust
pub struct MemoryAccessFuture {
    is_first_poll: bool,
}

impl Future for MemoryAccessFuture {
    fn poll(mut self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<Self::Output> {
        if self.is_first_poll {
            self.is_first_poll = false;
            Poll::Pending
        } else {
            Poll::Ready(())
        }
    }
}
```

### The Rust lang
So far we have covered all the essential code to implement an feature complete async memory access benchmark.
Obviously I omitted quite a lot technical details and some engineering tricks, 
the full code is available at the [GitHub repo](https://github.com/XiangpengHao/async_bench).

Before we continue to the experiments and benchmark section, I would like to share some thoughts on the rust language.

From my perspective, rust is better than c++ in almost every aspects.
System programming is difficult, it often needs to deal with the most challenging and error prone problems,
such as concurrency and crash consistency.
C++ is not only bad at handling these issues, but also deceptively easy to write incorrect code.
It feels like this language is encouraging you to make the complex problem even more chaotic.
Coding in rust feels the opposite way. 
The compiler forces you to think thoroughly before making any decisions:
you need to carefully think about heap allocation, nullable, lifetime and concurrency.  


## Section 4: Benchmark
The following figure shows the performance of async vs sync.
We can see the async version is about 4x faster than the sync version -- remember our queue size is exactly four.
This indicates that the majority of the synchronous time is wasted on the memory stall, 
which is the main selling point of async memory access.
![](/async/perf1.png)

Switching tasks, however, comes with costs, especially when the memory is already in the cache.
As shown in the following figure, where the array size is relatively small and all the workloads can fit into the CPU cache.
In this case, async memory access is a lot slower than the sequential access. 
![](/async/perf2.png)


## Section 5: Discussion
TBD



[^1]: Exploiting Coroutines to Attack the “Killer Nanoseconds”
[^2]: Asynchronous memory access chaining.