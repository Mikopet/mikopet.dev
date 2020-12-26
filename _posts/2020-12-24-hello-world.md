---
layout: post
title: "println!(\"{} World!\", \"Hello\");"
date: 2020-12-24
categories: architect
lectors: sagikazarmark, noslopy
---

### Abstract

Almost every development themed blog starts with the development of the very same blog. Why is that? _It is because:_

> We coders love to create, love to achieve. It is a game for us to challenge ourselves every damn day.
> 
> -by me, 2020. Christmas Eve

This blog is not an exception from that rule either, although it takes a slightly different approach.  
I want to guide you through the thoughtprocess of said new project:
how I planned and would have built this blog, how it should have worked and how it failed (before I could have even used it).

And good Lord ... **it will be such and overkill!**

#### Why, Peter? Why would you do this?

_Because simplicity is the Way_, and I believe there is no need to solve something overcomplicated. This solutions just lead to more issues and complexity.
Therefore I will fail...

...and one can learn the most from failure!

---

### Planning

The purpose of a blog is to deliver information to the public.  
_Organized. Categorized._

That is our goal, so let us approach from this angle.

This is technically just a large document sent over the internet.
We saw it a million times, we know exactly how it works. But are there other things in the background?

```qml
╔════════╗   "content"   ╔════════╗
║ SERVER ║——————————————>║ CLIENT ║
╚════════╝               ╚════════╝
```
{:.boxes}

Yeah, there are. We know the content needs to be created and maintained. So maybe there is an editor somewhere in the process.  
Thus (inevitably) we are in need of a back-office system.  
So the content is edited on this _admin_ panel.
We need to make sure that only the appropriate people have access to the system which begs for some sort of authentication.

Let us say out loud: we want an application to manage the contents of the ... of the?! ...

... of the other application who displays the contents.

```qml
╔══════════╗ "give me contents plz" ╔═══════════════╗
║          ║———————————————————————>║               ║
║  CLIENT  ║                        ║    DISPLAY    ║
║          ║<———————————————————————║  APPLICATION  ║
╚══════════╝      "here it is"      ║               ║
                                    ╚═══════════════╝
                                                  ^  
                             "giving all content" |  
                                                  |  
                                    ╔═══════════════╗
 ╔═══════╗ "there is a new content" ║               ║
 ║ ADMIN ║—————————————————————————>║  BACK-OFFICE  ║
 ╚═══════╝                          ║  APPLICATION  ║
                                    ║               ║
                                    ╚═══════════════╝
```
{:.boxes}

The connection between the back-office and the display app is intriguing. The content is stored in the back-office database, so are the different assets.  
Because we expect a large number of visitors, we should probably generate static documents from the content.  
(yes, as most of the crappy blogs around here. Seems pretty simple, but wait for it)

Tags section is an easy feature to add. But what about the comment section? That is not static content, and we also need to be able moderate it somehow.  
Let us not make it too easy: we should differentiate _content managers_: some of them should be responsible for the content, some of them should moderate comments.  
So we need authorization too. Maybe adding RBAC is the right solution?

```ruby
╔══════════╗ "give me contents plz" ╔═══════╗                  
║          ║———————————————————————>║       ║<———————————————┐ 
║  CLIENT  ║                        ║  D S  ║     regenerate | 
║          ║<———————————————————————║  I E  ║    static docs | 
╚══════════╝  "this post will do"   ║  S R  ║  (by tags too) | 
                                    ║  P V  ║                | 
╔══════════╗ "gimme content by tag" ║  L I  ║<———————————┐   | 
║          ║———————————————————————>║  A C  ║  regenerate|   | 
║  CLIENT  ║                        ║  Y E  ║     comment|   | 
║          ║<———————————————————————║       ║     section|   | 
╚══════════╝   "here it is (#asd)"  ╚═══════╝    of given|   | 
                                                     post|   | 
╔══════════╗ `new comment`: "this site sucks" ╔═══════════╗  | 
║          ║—————————————————————————————————>║           ║  | 
║  CLIENT  ║                                  ║           ║  | 
║          ║<—————————————————————————————————║  COMMENT  ║  | 
╚══════════╝ "we know. thanks for your reply" ║           ║  | 
                                              ║  SERVICE  ║  | 
╔══════════╗ `new abuse report`: "comment #1" ║           ║  | 
║  CLIENT  ║—————————————————————————————————>║           ║  | 
╚══════════╝                                  ╚═══════════╝  | 
                         ╔═══════════════╗<————————————┘ ^   | 
╔══════════╗             ║               ║ alert to      |   | 
║ CONTENT  ║             ║               ║ admins        |   | 
║ MANAGER  ║             ║  BACK-OFFICE  ║               |   | 
╚══════════╝             ║               ║———————————————┘   | 
 |                       ║  APPLICATION  ║ flag comment      | 
 └——————————————————————>║               ║ as appropriate    | 
   `new post`: "k8s.js"  ║               ║                   | 
                         ╚═══════════════╝                   | 
                             | ^ | deliver the               | 
 ╔═══════╗ "ABUSE!!44!four!" | | | new post ╔═════════════════╗
 ║       ║<——————————————————┘ | └—————————>║                 ║
 ║ ADMIN ║                     |            ║ CONTENT SERVICE ║
 ║       ║—————————————————————┘            ║                 ║
 ╚═══════╝  "nah, thats OK"                 ╚═════════════════╝
```
{:.boxes}

And do not forget, we need to separate the back-office frontend code from the backend. So in fact those are rather two apps.

But can we manage more entities in this application? Why not! Just apply some route magic.  
Obviously, we want to do all of this in a fashionable manner. So we **have to** use microservices with auto scaling.

Finally, we have the perfect reason to add Kubernetes to the mix. __* evil laugh *__

---

### Conclusion

Did I just plan the IT architecture and infrastructure for a segment of a billions USD worth global market?  
Yeeeeeah... broadly. Now I have a universal solution for hosting any online newspaper/blog.  
I assume most of these "blog" platform companies have something like this.

Nevertheless, I just tossed in some buzzwords: the job is undone.

But I am not a company (that is actually a lie), and need no such complexity.  
This is how I failed this project _before it started_.

A simple HTML document generated from markdown is more than enough for me at this point.  
With a third-party comment service ;-)

**This the concept of this blog. Modeling, planning, maybe some practical implementation.  
Trying out technologies, experimenting, and failing....a lot!
Let us learn together...**

> The task is done; the Maker rests.
>
> -Imre Madách, The Tragedy of Man, 1883