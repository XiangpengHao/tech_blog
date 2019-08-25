---
title: "[Debugger] Memory Visualizer?"
date: 2019-08-24T18:55:40-07:00
draft: false 
---

For months I've been imaging how beautiful my life can be if `lldb` (or less likely `gdb`) has something called `memory visualizer`.

As my core research goal is to design efficient data structures that fits any workload on any devices.
I frequently need to check how my data structure really looks like in the memory, 
and how it grows/shrimps on certain access pattern.
What's more, a memory visualizer can be extremely helpful when debugging concurrency bugs,
because you never know where the bugs is, and a visualizer just adds **much much more insights than breakpoints**.

### Visual Studio 

Visual Studio has an extremely helpful debugger, 
and they're kind enough to allow you to write [custom viewer](https://docs.microsoft.com/en-us/visualstudio/debugger/viewing-data-in-the-debugger?view=vs-2019), which is very close to a memory visualizer.
The problem is I'm never able to use Visual Studio for more than 10 mins, they have very scrappy user experience and I simply found it unusable.

So the only solution is to build my own visualizer.

### Cytoscape.js

[Cytoscape.js](http://js.cytoscape.org/):  A (relatively) new JS framework designed for graph visualization. 

It has easy-to-use interface, the UI looks good, the performance is decent as well.

But they are really dedicated to general purpose graph, **not trees**, in other words, they lacks a lot of important features that a tree can have.

### ECharts

[ECharts](https://echarts.apache.org/en/index.html): a chart generator open sourced by Baidu.

I'm never a fan of this company, but their ECharts is awesome. Powerful, interactive, and performant.  

They have native support to trees, very nice. But at this point I'm thinking about something more,
since anyway I need to build my own visualizer, why not ultimately build a data structure analyzer?

So I decided to use something more flexible and customizable.


### D3

Every time I tried to use [D3](https://d3js.org/), I found ECharts has done exactly what I needed, but unfortunately, this time D3 has to be the choice.

D3 is shockingly low-level and I can't believe this can be called a library on first sight.
But it turns out to be very useful when manipulating the svg.
 

## My solution, all together

1. Use [rapidjson](http://rapidjson.org/) (C++) to serialize my data structure, and save to a file.

2. Use [Vuejs](https://vuejs.org/) (my old friend) and all the bundled kit to quickly build a webpage.

3. Use D3 to draw the data structure.

Checkout [demo](https://xiangpenghao.github.io/tree-visualizer/), [code](https://github.com/XiangpengHao/tree-visualizer).

![](/img/tree-visualize.png)


## Future work

Integrate with [Debug Adapter Protocol](https://microsoft.github.io/debug-adapter-protocol/).

Make a plugin for both [lldb](https://lldb.llvm.org/) and [vscode](https://code.visualstudio.com/)

But obviously this won't happen in the near future :(

