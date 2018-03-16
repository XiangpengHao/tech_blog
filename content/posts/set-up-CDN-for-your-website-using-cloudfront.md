---
title: "Set Up CDN for Your Website using AWS CloudFront"
date: 2018-03-16T01:09:12-07:00
draft: false
---

The server of my [home page](https://www.haoxp.xyz) is located at Seattle where both Canadian and American can have fast access to. 

The problem arises when I want to share my ideas with other parts of the world, say India, which is too far away from my server and needs up to 2s to establish the connection. 

In this post I'll discuss how to set up CDN for my static website, I'll use `https://haoxp.xyz` as an example.

#### Why not CloudFlare?
To be honest, the first idea came to my mind is to use CloudFlare, which is professional, easy-to-use and a lot of my friends are using it. 

The problem is they don't support CNAME on their [free plan](https://www.cloudflare.com/plans/), which means you should transfer your nameserver to CloudFlare, which is not an option for me since I have a lot of other services in [HURRICANE](http://he.net/).

#### Why AWS?
AWS is cool.

#### Show me your results
I use this [tool](http://ping.pe/haoxp.xyz) to test latency and here are the speed comparisons.

Before
![before](/img/before.png)

After
![after](/img/after.png)

I highlighted locations where latency is higher than 200ms.

After correctly setting up the CDN, we can access the website even in China!

#### Custom Domains and their SSL Certs
In 2018, you have various ways to get a nice free SSL certificate, but the easiest on in our scenario is to
**get a wildcard-supported SSL certificate on AWS for free**

It's too trivial to cover the simple steps, so I just skip it.


#### Create the Distribution
I won't explain everything in detail but just to mention the keywords and some critical steps.

1. Register an AWS account and go to CloudFront management

2. Create a distribution and click get started in the `web` section

3. Add origin domain name, here I'll use `www.haoxp.xyz`. Note that CNAME at zone apex is not allowed, which means typically you cannot use root domain (like `haoxp.xyz`) here.

4. `haoxp.xyz` can only be accessed using HTTPS protocol, so I choose `HTTPS only` in origin domain protocol and direct all HTTP traffic to HTTPS in the `Viewer Protocol Policy`

5. Then I add my `CNAMEs` to `Alternate Domain Names`, choose Custom SSL certificate we generated above.

6. Scroll to the bottom and click `Create Distribution`

It takes up to 20 mins to get everything deployed and any modification will lead to another 20 mins wait, so you probably need to think twice before you click `Create Distribution`.

#### Conclusion
Now I have my websites deployed all over the world, congratulations!

But there is no free lunch, CDN is not always good, especially in small traffic websites. The CDN provider will invalidate the cache if it doesn't receive enough requests for a certain time, thus the website will be slower for having multiple round trips to the origin server.