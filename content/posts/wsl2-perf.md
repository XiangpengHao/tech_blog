---
title: "Install Perf on WSL2 (with unwind and symbols)"
date: 2020-09-09T12:39:03+08:00
draft: false 
---

WSL2 don't have `perf` and we can't install it from Ubuntu apt because WSL2 has its own modified linux kernel (and perf requires a match with the kernel version).

To install `perf` on WSL2, we need to clone the modified kernel and compile it with proper dependencies.  

```bash
sudo apt install flex bison gcc

# Clone the kernel from MS repo
git clone https://github.com/microsoft/WSL2-Linux-Kernel --depth 1

cd WSL2-Linux-Kernel/tools/perf

# Optional dependencies to unwind stack and resolve symbols
sudo apt install libnuma-dev libunwind-dev dwarfdump libdw-dev libelf-dev libiberty-dev

make -j4

sudo cp perf /usr/local/bin
```

### Bonus
I use the awesome [`flamegraph`](https://github.com/flamegraph-rs/flamegraph) to automatically generate interactive flamegraph.



