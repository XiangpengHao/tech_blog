---
title: "Digital Signatures in Plaintext"
date: 2018-03-22T15:03:41-07:00
draft: true 
---

tl;dr

People in the field of cryptography tend to use lots of mathematical formulas to explain simple things, which, they think may gain some extra security.

In this post I'll discuss the concept of digital signature in plaintext and try to avoid using the difficult-to-understand terms.

#### Why we need digital signatures?

We want to achieve data **integrity**, it's very similar to the `MAC (Message Authentication Code)` in the symmetric encryption case, the difference is we no longer need to share a secret key in advance. 

What's more, the signature enables a recipient to believe that the message was created by a known sender (**authentication**), and the sender cannot deny having sent the message (**non-repudiation**). These two features only exist in the public key encryption.


#### How does it work?
The sender encrypts the message using his **private key**, the receiver decrypts the message using sender's **public key**.

It's kind of counter-intuitive, but remember, we focus on **integrity** but not *secrecy*.

1. Authentication: if the receiver can decrypt the message using sender's public key, then the message must be created by the sender.

2. Integrity: no one else can modify the message without breaking the encrypted bytes, which means, as long as we can successfully decrypt the message, it's not modified.

3. Non-repudiation: if the message was encrypted using sender's secret key, then it's created by the sender since no one else has the key.


#### Can you give me a practical scheme?

We can use the RSA scheme and refer to <a href="#how-does-it-work">here</a>.

The only problem is we probably don't want a signature having the same length as the message do, so in most cases, we `hash` it first.

The signing pipeline is like: 

`message` -> `hash(message)` -> `private_key_encrypt(hash(message))`

And the authing pipline is like:

`private_key_encrypt(hash(message))` -> `public_key_decrypt(...)` -> `hash(message)`

`message` -> `hash(message)`

and we compare the two hash value to determine whether to accept it or not.

#### It's so simple, why they made it so hard to understand?
Ok, you introduce them, below are some advanced topics they are discussing.

#### The Rabin signatures

- Key generation: choose two random $p, q$ that are equal to $3\;(mod\;4)$, these are the secret/signing key. The public key is $n=p*q$.

- Signin: to sign a message m, output $e=\sqrt{m}\;(mod\;n)$.

- Verification: to verify that e is a valid signature for m, check that $e^2=m\;(mod\;n)$.

- Problem: we can steal the private key on a single query and it's difficult to compute a signature.

- Fixing the problem: we `hash` the message first, $x^2=h(m)\;(mod\;n)$.

- Further problem: the fact that h is collision resistent **does not tell us anything about the hardness of this question**, which means, we have no way to **prove** it's secure, even if h is collision resistent.

#### Making this provably secure
We don't have enough intelligent to prove it, even we use it in practice. The good thing is we also don't know it is insecure.

But there is still something we can do to publish a paper, the `random oracle model`. The intuitive explanation is, we suppose the h is completely random, and want to see if it is secure in this setting. If it is, we say it is secure in `random oracle model`, else it's not secure in the origin question. The problem is what if it is secure in random oracle model, we have to prove it is secure, which I don't want to discuss in this post.

- random oracle thesis: if a protocol has a proof of security in the `random oracle model`, then it will be secure when instantiated with a "sufficiently crazy" hash function.


#### From one-time scheme to many-times scheme
We do this in two steps:

1. Get a stateful signatrue schemes using a tree of signatures

2. Make it stateless using pseudo-random functions.



<script type="text/x-mathjax-config">
MathJax.Hub.Config({
  tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}
});
</script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
