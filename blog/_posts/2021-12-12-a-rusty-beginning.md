---
layout: post
title: "A rusty beginning"
date: 2021-12-12
category: blog
tags: rust advent-of-code
lectors: rust-community
image: https://www.apriorit.com/images/articles/Rust_language_tutorial.jpeg
---

I am trying to write this post for almost two to three months now...
and I am getting the feeling, it is something that cannot be done. Ever...  
> Anyhow, content must be born!<!--more-->  
>  -by me, again

#### How was my first "month" with Rust?

I have to say: **I love Rust**... and I hope Rust loves me back. Nevertheless, that was not an easy ride...

I started to experiment with Rust perhaps at the end of September. Sure, I did run some snippets before that...
but never sat down to learn it.  
In this case, the approach was something else again, I needed to write some software for business reasons, and well,
I was not programming at that point for a half to whole year...

My choice fell on Rust.
> Why not? Why should not I learn it now by creating some meaningful thing?!

Well, there are a lot of reasons why not. However, my decision was made, and I did two little projects.  
But what did I learn?

#### Rust is unique!

When one begins to deal with this language - regardless from which area (s)he comes - will face new approaches:

##### Rust is not object-oriented

Though, it has a few features which can be tagged as "[object-oriented]", because Rust is influenced by a few OOP
languages and that shows up sometimes in the syntax too.  
We have `Struct` and `Enum` and we can `impl`ement methods for them. **Encapsulation** is present...

... while **inheritance** is not. Although, there are `trait`-s, so you can share code.

In any way: you can create OOP-like code in Rust if you insist.

##### Rust is not functional

Well, at least it is close to that. I mean, by default Rust do not want to be functional,
but a lot of features of this language is definitely functional.
We can say that too, Rust is influenced by a lot of [functional] paradigms.

We have iterators, we have closures...
> Overall, Rust does in fact adhere to many FP principles, though not all.

In detail, you can read about this on [FP Complete].

##### What is Rust then?

Well, we can say that Rust is multi-paradigm, but basically: **Rust is imperative**.

Designed for performance and safety, especially safe concurrency.
One of the most powerful features is, that Rust does a lot of correctness checking at compile time.
Hence, there is no garbage collection at all, still, it can guarantee memory safety!

Rust has been called a systems programming language... but to be honest: you can do basically everything with it.

#### What do I do with it?

After my two little projects in the autumn, I began the [Advent of Code] in December.  
This is some kind of competition between the participants with cute algorithmic tasks. Though, it was not about
competing with others for me but learning.

Well, I did learn a lot.

First, I learned humility. **Rust is hard!**  
Perhaps you are a professional, but the learning curve of Rust is very steep. Initially, you do not really experience
success until you understand how Rust works.

But I learned about how _software_ should be written. The whole language is a best practice.
Just very hard to understand at the first sight.

I learned not to be afraid of complex things. Now I know, it will be worse over time.

Nonetheless, I have several ideas and projects... and at this point, Rust is the closest language for me,
so I hope I will do plenty of things.  
And even I have a little contribution in the `yew` crate already!

#### What should you do with it?

**Learn it!** Okay, okay... I am not saying that you have to switch to Rust, but it is definitely worth a look.

 - Rust forms how you think about types and values resting in memory. How you access them... how you _should_ access them.
 - Rust guides you on how not to make mistakes.
 - Rust loves you.

Have no doubts: it is not a walk in the park or a course for the faint-hearted...  
... yet I recommend it to anyone who is enough determined to check it out!

[object-oriented]: https://doc.rust-lang.org/book/ch17-00-oop.html
[functional]: https://doc.rust-lang.org/book/ch13-00-functional-features.html
[FP Complete]: https://www.fpcomplete.com/blog/2018/10/is-rust-functional/
[Advent of Code]: https://adventofcode.com
