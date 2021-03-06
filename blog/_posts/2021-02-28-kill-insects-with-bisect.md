---
layout: post
title: "Kill insects with &quot;bisect&quot;"
date: 2021-02-28
category: blog
tags: bug bash git bisect math python selenium test
lectors: tolcso
image: https://www.tutorialdocs.com/upload/2019/01/git-bisect-01.png
---

One of the most magnificent days of all times your boss finds you and cloud your thoughts with an extremely unpleasant situation:
**There is a serious malfunction in the main business logic!**

Nobody knows when or why it was implemented this way... that part of the codebase has not been touched by anyone for ages and it worked before... That is a mystery...

<!--more-->

### Solve this!

The first thing you should investigate is whether there are any tests present for that function, and if there are: why are those tests **false positive**?
This is the better outcome because one only needs to fix some tests according to the current _valid_ behaviour. And of course, the code after all.

#### But what to do if there are no tests for that operation?

Well, I am sure you know that: **Make some!**

For example, I used to have a feature in this blog on the index page. This feature showed the [tags] over the post excerpt.
But I redesigned it, so I do not have this feature anymore. My test checks if there is any `#` in that line.
Let us say: this is the bug we are searching for now.

```python
DEST_URL='http://localhost:8080'

import unittest
from selenium import webdriver
from selenium.webdriver.common.proxy import *

class WebInterfaceTest(unittest.TestCase):

  def setUp(self):
     self.driver = webdriver.Firefox()

  def tearDown(self):
     self.driver.quit()

  def test_web_interface(self):
    self.driver.get(DEST_URL)
    self.assertIn(
      "#",
      self.driver.find_elements_by_class_name("date")[0].text
    )

if __name__ == "__main__":
  unittest.main()
```

If you run this test now, it is failing of course. That is valid because the function is broken now. But we know it worked some time in the past.

> Who cares? Just fix the code and move on!

**You can say in your case. And you are right**... well, at least partially.
You need to know when and why that bug appeared. Not in order to blame the author but because there must be some reason it appeared.  
So with that careless behaviour, your "fix" can cause other bugs in the system unwittingly.

#### You need to find the root cause!

Let us say, we have a [sigmoid function] implemented by somebody, but we do not know where its [inflexion point] is.

We only know that value is a positive integer between 1 and 100.
We know, and we can prove that **100** as the parameter returns `true` in this function, while **1** as the parameter returns `false`.  
To find the right value (the point on the [abscissa]) we need to check all the possibilities!

Or maybe not... There is the mathematical [bisection method] (there are better methods for this particular problem, but now go with this).
Starting with the middle of the possibilities:
 - Check **50**. Is it `true`? Yes
 - Check **25**. Is it true? No. Is it `false`? Yes.
 - Check **37**. Is it true? No. Is it `false`? Yes.
 - Check **43**. Is it `true`? Yes.
 - Check **40**. Is it true? No. Is it `false`? Yes.
 - Check **42**. Is it true? _No_. Is it false? _No_.

We just found the solution in **6 steps** instead of the needed **42 steps** if going incrementally!

This is what `git bisect` does:  
Goes back in the repository and `checkout` the next commit by bisection, so you can decide it is failing or not. According to your answer, it steps forward or backwards.
Even on large numbers like tens of thousand commits it can run very quickly. And this is the deal here:

**In your case, you need to avoid checking a vast number of irrelevant commits.**

#### Testing with git bisect

We have the test, we have the searching method. Put it together.

##### It is mandatory not to commit the test file yet! Otherwise, it will be versioned and disappears between checkouts.

I know of a working version where I introduced this feature(`f69a1d88`). And a "broken" version where it is not working (where we are yet, aka. `HEAD`).  
To start the debugging for my case just run:

```bash
$ git bisect start HEAD f69a1d88
$ python test.py
```

According to the outcome we just need to define to the bisecting process which way to continue. Hint `good` or `bad` as argument of the bisect command, and run the test again.

```bash
$ git bisect <good|bad>
$ python test.py
```

After a few steps we are done, and we get something like this:

```plaintext
d4f8a03852501f57d3b568d98affddef9d3b3056 is the first bad commit
```

This is very satisfying... but with a truly huge number of commits, it is still a pain.
Fortunately, we can automate it:

```bash
$ git bisect start HEAD f69a1d88
$ git bisect run python test.py
```

And the outcome is something like that:

```python
running python test.py
.
----------------------------------------------------------------------
Ran 1 test in 5.147s

OK
Bisecting: 4 revisions left to test after this (roughly 2 steps)
[8c0451012b580e9bc10c53716b9c62869386b693] CONTENT #2: fixing more grammar according to lecturers
running python test.py
.
----------------------------------------------------------------------
Ran 1 test in 4.703s

OK
Bisecting: 2 revisions left to test after this (roughly 1 step)
[fcf27850ef913dde736d2c6521301b1367987056] CONTENT #2: add cover image
running python test.py
.
----------------------------------------------------------------------
Ran 1 test in 4.769s

OK
Bisecting: 0 revisions left to test after this (roughly 1 step)
[8ea6de280bcc6c1d4dce149ea9710c166a2691b3] some style facelift
running python test.py
F
======================================================================
FAIL: test_web_interface (__main__.WebInterfaceTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/home/mikopet/Git/mikopet.dev/test.py", line 17, in test_web_interface
    self.assertIn(
AssertionError: '#' not found in 'February 12, 2021 · 0 Comments · 3 min read'

----------------------------------------------------------------------
Ran 1 test in 4.930s

FAILED (failures=1)
Bisecting: 0 revisions left to test after this (roughly 0 steps)
[d4f8a03852501f57d3b568d98affddef9d3b3056] redesigning post headers and footers
running python test.py
F
======================================================================
FAIL: test_web_interface (__main__.WebInterfaceTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/home/mikopet/Git/mikopet.dev/test.py", line 17, in test_web_interface
    self.assertIn(
AssertionError: '#' not found in 'February 12, 2021 · 0 Comments · 3 min read'

----------------------------------------------------------------------
Ran 1 test in 4.752s

FAILED (failures=1)
d4f8a03852501f57d3b568d98affddef9d3b3056 is the first bad commit
commit d4f8a03852501f57d3b568d98affddef9d3b3056
Author: Peter Mikola <mikopet@gmail.com>
Date:   Sun Feb 21 14:28:06 2021 +0100

    redesigning post headers and footers

 _includes/post-attributes.html | 14 --------------
 _includes/read-time.html       |  4 ++++
 _layouts/post.html             | 11 ++++++++++-
 pages/index.html               | 10 +++++++---
 run.sh                         |  2 +-
 style.scss                     | 11 +++++++++++
 6 files changed, 33 insertions(+), 19 deletions(-)
 delete mode 100644 _includes/post-attributes.html
 create mode 100644 _includes/read-time.html
bisect run success
```

In 27 seconds... without touching anything! That is a remarkable debugging process!

This can only work because the test running process returns an exit code every time, and git can decide that it is good or bad. Usually, `exit code 0` is `good`, the others are `bad`.

Well, in your case:

> You always need to dive deep into the _cause and effect_.  
> Perhaps, the feature is broken...  by design.


[tags]: https://mikopet.dev/tags
[sigmoid function]: https://en.wikipedia.org/wiki/Sigmoid_function
[inflexion point]: https://en.wikipedia.org/wiki/Inflection_point
[abscissa]: https://en.wikipedia.org/wiki/Abscissa
[bisection method]: https://en.wikipedia.org/wiki/Bisection_method

