---
title: "A Guide to Locate Linux Kernel Bugs"
date: 2020-02-19T12:40:12-08:00
draft: false 
---

Recently we encountered yet another kernel bug: our data structure performs 3-4x slower on kernel v5.2 than on kernel v5.5.x

So I tried to figure out exactly which commit caused the bug, and which commit fixed it. 
This is a very long journey, and it is extremely difficult for non-kernel developers to work on it.

I found these experiences/lessons to be useful, hope they are helpful to you as well.

### Step one: find the correct kernel version

Modern linux kernel version obeys the following convention[^1]: 

```
    (Kernel Version).(Major Revision).(Minor Revision) - (Patch)
```

For example, kernel `4.19.84-microsoft-standard` means this kernel stems from the 19th major version of v4.x,
it has 84 minor revision and it's patched by microsoft.
Different linux distributions may have different patch convention, for example, kernel on arch linux may look like 
`5.5.4-arch1-1`

Most linux minor revisions are rebased from upstream changes, this means that code changes from `v5.2.x` are actually from, for example, `v5.3`.

Given what we have discussed, to narrow down the problem space, we need to find a minor revision that fix the bug.
This involves switching between different kernel versions, which is scary and error-prone. 
Luckily there's a package called `downgrade` (arch linux only[^2]) that can help.

Through interactive interface, the downgrade allows users to easily switch between the package versions, this of course include the package `linux`.

```
sudo downgrade linux
```

That's it!


### Step two: read the changelog

After several **reboots**, we can successfully locate a specific kernel version, say, v5.3.8, that fixed the bug.
But we want to know exactly which commit caused the bug.

Unfortunately I didn't have anything better than reading the changelog and guessing the bug.

The kernel changelog can be found here: https://cdn.kernel.org/pub/linux/kernel/v5.x/ChangeLog-5.3.8
The changelog of minor revision is usually within 200 commits, so it's relatively easy to go through each commit and filter them by their commit message.

In my case, I know the commit should be related to memory systems, so I searched `memory`, `fault`, `dax`, and find three candidates.
Then I dig into the related discussions and find one commit that is particularly related to my case.

The commit message says this commit fixed a bug introduced by another commit.

To verify this, we'll need to find a kernel version that happens exactly before that bug.


### Step three: find a kernel version containing a commit

The job is simple: given a commit hash, find a kernel version that containing the commit.

Usually GitHub has this handy function:
![](/img/linux-gh.png)

But as you might have noticed, the linux repo on github **DO NOT tag minor revisions**, it only has release candidates (rc).
This confuses me a lot, and I ended up cloning the whole linux repo from kernel.org.
Luckily the git repo from kernel.org does have minor revision tags.

We can then find the related tags by:
```
git tags --contains 23c84eb7837514e16d79ed6d849b13745e0ce688
```
It will list all the linux kernel containing that commit.

Unfortunately, this still does not work. Because as I said, code changes to minor revisions are typically rebased from upstream changes.
Querying the upstream commit hash will only show the upstream kernel versions, this means that we cannot find the all the kernel versions containing the changes, because there're multiple equivalent commits (due to merge and rebase).

I don't have any better ways to find equivalent commits, so I decided to research the commit in the changelog.
The following screenshot shows the equivalent commit of `23c84` is `111b0`.
![](/img/changelog-linux.png)

```
git tag --contains 111b055e43cbca1761eaea0812e35dea556cb8d5
v5.2.10
v5.2.11
v5.2.12
v5.2.13
v5.2.14
v5.2.15
v5.2.16
v5.2.17
v5.2.18
v5.2.19
v5.2.20
v5.2.21
v5.2.3
v5.2.4
v5.2.5
v5.2.6
v5.2.7
v5.2.8
v5.2.9
```
From the command above, we know this commit first comes in v5.2.3

Switching between v5.2.3 and v5.2.2 confirmed that this commit did introduce the bug I was expecting. 

Great!




[^1]: https://askubuntu.com/questions/843197/what-are-kernel-version-number-components-w-x-yy-zzz-called/843198#843198

[^2]: https://github.com/pbrisbin/downgrade