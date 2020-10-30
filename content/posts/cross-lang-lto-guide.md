---
title: "Guide to LTO between Rust and C/C++"
date: 2020-10-29T19:23:31+08:00
draft: true
---

I use Rust in one of my research projects.
The project was originally developed in C++, and because [C++ is bad](https://da-data.blogspot.com/2020/10/no-c-still-isnt-cutting-it.html) we decided to add new features primarily in Rust. 

Calling Rust from C++ is simple and easy (thanks to the excellent [cxx](https://github.com/dtolnay/cxx) project), but we soon find some performance regressions that didn't appear in the C++ code. 
Specifically, we see many tiny Rust functions in [flamegraph](https://github.com/flamegraph-rs/flamegraph) that wouldn't surface up in C++.
The reason is that those Rust functions crossed language boundary and the optimizers have no way to optimize them.

LTO (linking time optimization) can save us because during linking time optimizers can gather enough knowledge about the whole program and (presumably) can find new optimizing opportunities.   

I try to enable LTO in my project, but [it's not easy](http://blog.llvm.org/2019/09/closing-gap-cross-language-lto-between.html).
I was in the same situation as those Firefox guys:

> We were beginning to seriously question our understanding of LLVM's inner workings as the problem persisted while we slowly ran out of ideas on how to debug this further.

I spend about three whole days from zero knowledge on compilers to set up a (hopefully) functional LTO in my real project.
This post is not a step-by-step guide because things change rapidly, but rather it's a list of things we should take care of when incorporating LTO in our projects.
Nevertheless, I have an [example GitHub repo](https://github.com/XiangpengHao/cxx-cmake-example.git) which enables cross-language LTO between Rust and C++. If you have any problem building the code, you can check the GitHub action file, which set up the necessary building environment.


### Rust LLVM and C/C++ LLVM must match
The linking time optimizer requires both Rust and C++ to generate understandable bytecode, which means using the same LLVM version.

For this reason, some people suggested to [ship clang](https://github.com/rust-lang/rust/issues/56371) as a Rust component.


To check the Rust LLVM version:
```bash
> rustc --version --verbose                      
rustc 1.49.0-nightly (ffa2e7ae8 2020-10-24)
binary: rustc
commit-hash: ffa2e7ae8fbf9badc035740db949b9dae271c29f
commit-date: 2020-10-24
host: x86_64-unknown-linux-gnu
release: 1.49.0-nightly
LLVM version: 11.0
```

To check C/C++ LLVM version:
```bash
> clang -v
Ubuntu clang version 11.0.0-2
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/bin
Found candidate GCC installation: /usr/bin/../lib/gcc/x86_64-linux-gnu/10
Found candidate GCC installation: /usr/bin/../lib/gcc/x86_64-linux-gnu/9
Found candidate GCC installation: /usr/lib/gcc/x86_64-linux-gnu/10
Found candidate GCC installation: /usr/lib/gcc/x86_64-linux-gnu/9
Selected GCC installation: /usr/bin/../lib/gcc/x86_64-linux-gnu/10
Candidate multilib: .;@m64
Selected multilib: .;@m64
```

### Install a recent version of LLVM toolchain
LLVM has good support for Ubuntu/Debian based package manager; you can download the pre-built binary [here](https://releases.llvm.org/download.html).

I'm an Arch Linux user and at the time of writing LLVM 11 is [not available](https://www.archlinux.org/todo/llvm-11/) on AUR, so I need to compile it from source.

Compile LLVM toolchain is simple and staightforward.
Be sure to select at least `clang` and `lld` in cmake parameters.

To build LLVM with LTO support, we also need a linker plugin called `LLVMGold` (discussed later); we can enable it by specifying `-DLLVM_BINUTILS_INCDIR=/path/to/binutils/include`, more details [here](https://llvm.org/docs/GoldPlugin.html#how-to-build-it).

Building LLVM can take quite a while (it takes about 5 mins to build and consumes all my 96 CPU cores).

### Linker and linking plugin
"LTO support on Linux systems is available via the [gold linker](https://sourceware.org/binutils/) which supports LTO via plugins."

`ld` is the GNU linker and `lld` (or `ld.lld`) is the LLVM linker; we will stick to LLVM toolchain and use `lld` for all the linking jobs.

### ThinLTO and LTO
Covered [here](https://blog.llvm.org/posts/2016-06-21-thinlto-scalable-and-incremental-lto/), in a nutshell, ThinLTO is a new LTO that is faster to compile with similar runtime performance.

Rust supports ThinLTO since [this](https://github.com/rust-lang/rust/pull/58057).

### Compile Rust with ThinLTO
Covered [here](https://doc.rust-lang.org/rustc/linker-plugin-lto.html), with a few [caveats](https://github.com/rust-lang/rust/issues/60059), which means that until the issue is addressed, we need to compile with:
```bash
RUSTFLAGS="-Clinker=clang-11 Clinker-plugin-lto -Clink-arg=-flto" cargo run --release
```

Or:
```bash
RUSTFLAGS="-Clinker=clang-11 -Clinker-plugin-lto -Clink-arg=-fuse-ld=lld" cargo run --release
```

### Compile C/C++ with LTO
I use CMake and CMake supports LTO by:
```cmake
include(CheckIPOSupported)
check_ipo_supported(RESULT supported OUTPUT error)
if(supported)
    message(STATUS "IPO / LTO enabled")
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
    add_link_options(-fuse-ld=lld)
else()
    message(STATUS "IPO / LTO not supported: <${error}>")
endif()
```
`add_link_options(-fuse-ld=lld)` instruct CMake to use `lld` instead of `ld` (otherwise cmake insists to use `ld` even if you're using clang)


### Some results
The full code is [here](https://github.com/XiangpengHao/cxx-cmake-example/blob/master/main.cpp), I basically compared two functions:

```c++
int rust_echo(int val);
// Rust code:
// fn rust_echo(val: i32) -> i32 {
//     val
// }

int cpp_echo(int val)
{
    return val;
}

int test_rust()
{
    int sum = 0;
    for (int i = 0; i < 1000000; i += 1)
    {
        sum += rust_echo(i);
    }
    return sum;
}

int test_cpp()
{
    int sum = 0;
    for (int i = 0; i < 1000000; i += 1)
    {
        sum += cpp_echo(i);
    }
    return sum;
}
```

**Without** LTO:
```
Calling rust function, time elapsed: 1176600 ns.
Calling c++ function, time elapsed: 100 ns.
```

**With** LTO:
```
Calling rust function, time elapsed: 100 ns.
Calling c++ function, time elapsed: 100 ns.
```
