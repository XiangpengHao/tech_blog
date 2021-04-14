---
title: "Advanced Git Cheatsheet"
date: 2018-03-17T11:20:53-07:00
draft: true 
---

In this post, I'll cover some advanced git operations. The philosophy is to keep you git history clean and intuitive.

#### Change the last commit
```
git commit --amend
git commit --amend -m"new commit message"

git commit --amend --no-edit
# no-edit allows you to amend the last commit without editing the commit message
```

Amend command will replace the lastest commit with a new one, which means they have different hash value.

**Do not amend public commits**, others will get confused and it's complicated to recover from.

#### Combine serveral commits into one
```
git rebase -i <older-commit>
```
Then replace the `pick` on the second and subsequent commit with `squash`.

#### Go back to older commits

```
git checkout <commit>
```
You can go back to this commit with everything clean. If you want to make some changes, you need to create a new branch based on this checkpoint.

```
git reset <commit>
git reset <commit> --mixed
# mixed is the default option
```
Go back to some commit with working directory unstaged.

```
git reset <commit> --soft
```
Go back to the commit with working directory staged

```
git reset <commit> --hard
```
Go back to the commit with working directory clean, identical to the commit at that time.

```
git revert <commit_from>...<commit_to>
# revert takes ranges.
```
`git revert` will create a new commit with the reverse patch to cancle it out. **You should try it when it's a public commit.**

#### Create Tags
```
# create a new tag
git tag <tag>

# show tags
git tag

# push tag to origin
git push origin --tags
```

#### Using emoji in commit log
```
git commit -m":<emoji>: commit message"
```
You can find the emoji codes [here](https://gitmoji.carloscuesta.me/) and you should really follow the emoji conventions.

#### Pretty git log
Append these lines to `~/.gitconfig`, and try `git lg`
```
[alias]
lg1 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all
lg2 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all
lg = !"git lg1"
```
