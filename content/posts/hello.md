---
title: "Continuous integration for Hugo with Travis"
date: 2018-03-07T22:12:10-08:00
draft: false
---

Too troublesome, don't read.

It's a great idea to ship your static website by a single commit.

I use Travis for its simplicity and good reputation in open source community. But the command line tools enforced by them is just dirty and only introducing more troubles, especially when you are not a fan of Ruby.

The general idea is to build the Hugo site using Travis and then SSH deploy the static files to my server. I won't use GitHub pages until they support HTTPS on custom domains.
The final `.travis.yml` is shown below.
```
before_install:
- wget https://github.com/gohugoio/hugo/releases/download/v0.36.1/hugo_0.36.1_Linux-64bit.deb
- sudo dpkg -i hugo*.deb

script:
- hugo

deploy:
  - provider: script
    skip_cleanup: true
    script: rsync -avzhe ssh ./public/ hao@vul.haoxp.xyz:/home/hao/tech_blog
    on:
      branch: master

before_deploy:
- openssl aes-256-cbc -K $encrypted_b30cc9581a71_key -iv $encrypted_b30cc9581a71_iv
  -in deploy_tmp.enc -out /tmp/deploy_tmp -d
- eval "$(ssh-agent -s)"
- chmod 600 /tmp/deploy_tmp
- ssh-add /tmp/deploy_tmp
- ssh-keyscan vul.haoxp.xyz >> ~/.ssh/known_hosts
```

#### Install & build Hugo
It's deadly simple, no dependencies, zero configs just download the package and you are ready to go.

#### Prepare for SSH keys
I definitely don't want to publish my private keys so we should encrypt it before adding to the repository. Here I'll create a dedicated SSH key just for deploying so that it's easy to revoke.
```bash
ssh-keygen
```
Then we need to encrypt the key using the Travis command line tool (you should have ruby installed first)
```
travis encrypt-file deploy_tmp --add
```
The `--add` command helps you to add necessary configs to your `.travis.yml`

Then we add our public key to the server
```
ssh-copy-id -i deploy_tmp.pub user@host
```

#### SSH on Travis
If you follow the step above, the `.travis.yml` should have one line like 
```
- openssl aes-256-cbc -K $encrypted_b30cc9581a71_key -iv $encrypted_b30cc9581a71_iv
  -in deploy_tmp.enc -out /tmp/deploy_tmp -d
  ```
We move this section from before_install to before_deploy for security concerns (you know why). Then modify a little to output the ssh key to /tmp so that we may not touch the private key by  accident.
It's important to add following line to prevent confirming ssh key fingerprint when using `rsync`.
```
-ssh-keyscan host >> ~/.ssh/known_hosts
```

#### Deploy
With all these configured, you are ready to trasfer the files using tools like `rsync` or `scp`, I prefer `rsync` here.
```
rsync -avzhe ssh ./public/ hao@vul.haoxp.xyz:/home/hao/tech_blog
```
Now you are all set!

#### Conclusion
It wasted me ten commits before I get all these perfectly correct, but it's definitely worthwhile to investigate the time, since it's a "pain once, enjoy every time" job.

Now I commit and it will automatically deploy the page you're reading now.