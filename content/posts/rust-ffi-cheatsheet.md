---
title: "Rust FFI Cheatsheet"
date: 2020-09-25T15:09:06+08:00
draft: true 
---

Working in progress...


### C string to Rust string and vice versa
[source](https://stackoverflow.com/questions/24145823/how-do-i-convert-a-c-string-into-a-rust-string-and-back-via-ffi) 

```rust
extern crate libc;

use libc::c_char;
use std::ffi::CStr;
use std::str;

extern {
    fn hello() -> *const c_char;
}

fn main() {
    let c_buf: *const c_char = unsafe { hello() };
    let c_str: &CStr = unsafe { CStr::from_ptr(c_buf) };
    let str_slice: &str = c_str.to_str().unwrap();
    let str_buf: String = str_slice.to_owned();  // if necessary
}
```

### `PathBuf -> const char *path`

[source](https://stackoverflow.com/questions/38948669/whats-the-most-direct-way-to-convert-a-path-to-a-c-char)

```rust
use std::ffi::CString;
use std::os::raw::c_char;
use std::os::raw::c_void;

extern "C" {
    some_c_function(path: *const c_char);
}

fn example_c_wrapper(path: std::path::Path) {
    let path_str_c = CString::new(path.as_os_str().to_str().unwrap()).unwrap();

    some_c_function(path_str_c.as_ptr());
}
```

### Pass mutable pointers to a C function, which writes to the value
[source](https://stackoverflow.com/questions/42727935/passing-a-rust-variable-to-a-c-function-that-expects-to-be-able-to-modify-it)
```rust
unsafe {
    let mut v = std::mem::MaybeUninit::uninit();
    takes_a_value_pointer(addr, v.as_mut_ptr());
    v.assume_init()
}
```

### Link to a system library that doesn't have a rust binding yet
[source](https://s3.amazonaws.com/temp.michaelfbryan.com/linking/index.html)
```rust
// build.rs

use std::env;

fn main() {
    let project_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

    println!("cargo:rustc-link-search={}", project_dir); // the "-L" flag
    println!("cargo:rustc-link-lib=add"); // the "-l" flag
}

```


