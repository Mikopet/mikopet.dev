---
layout: post
title: "A client daemon? What?"
date: 2021-02-12
category: blog
tags: snippet bash discord
---

Have you ever been in a situation where you had no possibilities to solve the problem?  
I bet on it: **you were!** Do not worry, I am no different.  
But there is always a _workaround_.

<!--more-->

Last summer we worked from home and met on discord. Actually, that was not bad at all, and it was for free!  
I did use the official client on Linux which was an electron app. That worked properly... except I got `Segmentation fault` over and over!

Because I could not fix the failure due to the lack of competence and had no access to the source code: I did go with an auto-restart when the app crashed.

This snippet helped me:

```bash
#!/bin/bash

until /usr/lib64/discord/Discord; do
    echo "CRASHED with exit code $?. Respawning..."
done
```

In the first line, there is the [shebang] which tells the runner the path of the interpreter what we want to use.  
The `until` loop is the main logic of this snippet. In the `condition` there is the execution of the program which has no return value yet, so we are up to evaluate that somehow.  
In the UNIX-like systems is mandatory that a process have an [exit value]. Without errors it returns `0`, but with errors it returns something else, like `127`.

The next line is a simple `echo` command which uses `$?`. This is a special parameter which refers to the exit status of the most recently executed foreground pipeline. In our case, it is an integer which is greater than zero.

"Cannot it be zero?" You could ask.  
Yes, it can... but not inside the loop. Because the evaluation of the exit status is in the condition of `until`! So with closing discord properly the until exits as the program itself with the code `0`...

#### Can we do something more with this code?
Yes. First of all, to be universal we can make it independent from the operating system and the type of setup.
So we need to guess, where is discord installed.

```bash
#!/bin/bash

until $(which Discord); do
    echo "Discord CRASHED with exit code $?. Respawning..." >&2
done
```

We used the `$()` which is the way of [command substitution]. With that, we can get the standard output of the subcommand. Which is the `path` on the current system of `Discord` command.

We modified the echo line too: the name of the crashed program is in the message because we want to know, what crashed.  
At the end of the line, there is the `>` redirection operator which points to `&2`, the standard error. Because there is an error, and we want to send that in the proper [I/O stream].

#### How can I use this snippet for other commands easily?
Just catch an argument and use that in the `which` statement. Optionally you can catch a second argument for some delay between the auto restart. Some software require that.

```bash
#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'There is no command given. Correct usage of the `aus` is:'
    echo '$ aus command [sleep_time]'
    exit 0
fi

ST="${2:-0}"

until $(which $1); do
    echo "$1 CRASHED with exit code $?!" \
         "Respawning in $ST sec ..." >&2
    sleep $ST
done
```

First, we check whether any command is given to us. If not, we print some message.
After that, we put down the given `sleep_time` argument in a variable or set it to default `0`.
And the last step is when we run the command we do it by the given `command` argument.

We have no more task to do but copy this file to somewhere to autoload:
```bash
$ cp autorestarter_from_mikopet_dev /usr/local/bin/autorestart
```

And we can use it in the `.desktop` files as a prefix. For example we can edit the discord's file at `/usr/share/applications/discord.desktop`:

```ini
Name=Discord
StartupWMClass=discord
Comment=Discord with autorestarter
GenericName=Internet Messenger
Exec=autorestart /usr/bin/Discord
Icon=/usr/lib64/discord/discord.png
Type=Application
Categories=Network;InstantMessaging;
Path=/usr/bin
X-Desktop-File-Install-Version=0.26
```

[shebang]: https://en.wikipedia.org/wiki/Shebang_(Unix)
[exit value]: https://tldp.org/LDP/abs/html/exit-status.html
[command substitution]: https://www.gnu.org/software/bash/manual/html_node/Command-Substitution.html
[I/O stream]: https://man7.org/linux/man-pages/man3/stdin.3.html
