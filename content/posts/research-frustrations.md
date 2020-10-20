---
title: "System research frustrations"
date: 2020-10-19T14:58:31+08:00
draft: false 
---

> ... we see a thriving software industry that largely ignores research, and a research community that writes papers rather than software. -- Rob Pike, [Systems Software Research is Irrelevant](http://herpolhode.com/rob/utah2000.pdf)



I heard/experienced these from my system research daily.
I write them done not to complain or express my anger; instead, I know many people suffer from the same feeling: you are not alone.

These are common cases in system research, and the situation will unlikely to improve due to the nature of research prototyping. 

Many of these points are unfair to my advisors (which are very nice to students) -- these things will never happen if I talk more and express more of my feelings.


### One
Has to work on a pile of legacy code that is **not in good shape**.

Not in good shape (any of the following):

1. No tests

2. Benchmarks as tests

3. Take more than a minute to compile

4. Take more than a minute to verify(guess) correctness

5. Print error and runtime message to stdout or stderr or mix of them

6. Compile by concatenating every source file

7. Link by linking every shared library

8. Dead code, unused variables, orphan functions


### Two
You: Want to improve the codebase.

Your advisor/collaborators: Why? Do we need that? Isn't that a waste of time? Things have priorities.

### Three
You: Re-write a single line of code so it looks cleaner.

You: The benchmarks collapse because the code switched from an undefined behaviour to another undefined behaviour. 

### Four
You: Work hard for a whole week and finally get some numbers before the regular meeting.

You advisor/collaborators: I don't know how to interpret these numbers; why don't you do this and that before we have the discussion?

### Five
You: Add an absolutely-not-used if clause

Your code: Performance drops by 20%

### Six 
You: I'm thinking big!

You project: Most performance improvments come from profiling cache miss, page fault, contention and branch prediction.

### Seven 
You: Researching is not engineering!

You: Staring at [point six](#six)


### Eight 
Spend 10% of time prototyping, spend the rest of time debugging and profiling.

### Nine 
You: Work hard for five years and produce three papers that no body cares.

Your friends: Work in Snowflake, Bytedance, Ant Financial, TiDB etc...

### Ten
Adding more...
