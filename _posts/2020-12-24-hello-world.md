---
layout: post
title: "println!(\"{} World!\", \"Hello\");"
date: 2020-12-24
categories: architect
lectors: sagikazarmark, noslopy
---

### Abstract

Every blog about development starts with new development. Why is that? _It is because:_

> We coders love to create, love to achieve. It is a game for us to challenge ourselves every damn day.
> 
> -by me, 2020. Christmas Eve

This channel of information is not different. Just in approach.  
I want to guide you through the process:
how I plan this, how I build this, how it should work, how it failed (before I could use it)

And good Lord ... **I will do it as overkill as possible!**

#### Why, Peter? Why do you do this?

_Because simplicity is the Way_, and I believe there is no need to solve something excessively.
Therefore I will fail...

...and from failure can one learn mainly!

---

### Planning

Approach from the goal. The purpose of a blog is to give information publicly.  
_Organized. Categorized._

This is technically just a large document sent over the internet.
We saw it a million times, we know exactly how it needs to work. But are there other things in the background?

```qml
╔════════╗   "content"   ╔════════╗
║ SERVER ║——————————————>║ CLIENT ║
╚════════╝               ╚════════╝
```
{:.boxes}

Yeah, there is. We know the content needs to be created, maintained. So maybe an editor will do.  
Thus we are in necessity of a back-office system inevitably.  
Now we know, the content is edited in this _admin_ somehow in some format. We are in monstrous need of authentication.

Let us say it loud: we want an application to manage the contents of the ... of the?! ...

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

The communication between the back-office and the display app is intriguing. The content is stored in the back-office database as so the assets.  
Because we are counting an outstanding amount of visitors, the best if we give themselves a few generated static document.  
(yes, as most of the crappy blogs around here. Seems too simple for us, but wait for it)

Tags section is easy to make. But what about the comment section? That cannot be exclusively static, and we need to moderate it somehow.  
But not everyone can post and moderate if we have more _content managers_.  
We need authorization too. Maybe an RBAC helps.

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

And do not forget, we need to separate the back-office frontend code from the backend. So that is truly two apps.

But can we operate more entities from this only engine? Why not! Just some route magic.  
And we want to do all of this in a modern manner. We **must** use microservices. We must set up autoscale.

A Kubernetes cluster is needed too unequivocally. __* evil laugh *__

---

### Conclusion

I did just planned the IT architecture and infrastructure of a segment of a billions USD worth global market?  
Yeeeeeah... broadly. Now I have a universal solution for hosting any and many online newspaper/blog.  
I assume most of these "blog" platform companies have something like this.

Nevertheless, I just tossed some buzzwords: the job is undone.

But I am no company (that is actually a lie), and need no such complexity.  
This is how I failed this project _before it starts_.

A simple HTML document which includes the content from somewhere what compiles the markdown is more than enough for me yet.  
Maybe with a 3rd party comment service ;-)

**This the conception of this blog. Modelling, planning, maybe some practical implementation.  
Trying out technologies, make experiments, and fail!
We learn together...**

> The task is done; the Maker rests.
>
> -Imre Madách, The Tragedy of Man, 1883