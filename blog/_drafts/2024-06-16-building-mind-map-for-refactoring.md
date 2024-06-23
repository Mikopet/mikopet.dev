---
layout: post
title: "Building Mind Map for Refactoring"
date: 2024-06-16
category: blog
tags: rust servo refactoring
image: https://raw.githubusercontent.com/koutto/pi-pwnbox-rogueap/main/mindmap/WiFi-Hacking-MindMap-v1.png
---

Recently I embarked on a big challenge in my life. Namely, I started to contribute to two big open-source projects.
One of the projects is new and own, we do it with a small team and I am a core developer... and the other is this project's dependency: [Servo].

Now, what we have to about Servo is that it was created by Mozilla more than a decade ago and it was recently resurrected and transferred to [Linux Foundation Europe][lfe].
It is a web rendering engine by definition... but it does much more things like what a browser should be capable of.

The architecture is kind of a reformer. We are speaking about a task-based approach in a massively parallel setting.
This aims for high performance compared with competitors... but has its challenges too!

<!--more-->

Fortunately, Servo could exploit fearless concurrency provided by [Rust]:
> a new language designed specifically with Servo's requirements in mind. Rust provides a task-parallel infrastructure and a strong type system that enforces memory safety and data race freedom.

With memory safety in our heads, we can only imagine how complicated it could get. The base `servo` repository is around ~310k lines of Rust code (including whitespace and comments, but excluding tests, ~90k more),
but many functionalities were already outsourced to separate crates.
For comparison, `tokio`, one of the most popular Rust libraries is only ~112k lines of code. (using the same criteria)

The project is big, I doubt if someone is actually familiar with all the parts of the codebase (prove me wrong)... but the biggest issue is not this.
To me, it looks like the project is transitioning from a legacy something to a newer something. With a huge amount of technical debts...
mostly because 10 years passed and the technology around it changed a lot.

However, I decided to do some overhauling on the networking/persistence parts of the codebase!


### Where to start?

Fortunately, [Servo code] is modular, therefore all the logic we are looking for is in separate components in the `components/` directory. In my case, this is the `net` component.
So first thing I did was to reach out to contributors, **what are their opinions about this component, are there already some plans with it?**

Apparently not too much, just a little conversation about threads. Other than that, it looks like any ideas are welcome.  
**This article is about my ideas, primarily addressed to the contributors.**

### Some preliminary checks

The only thing I knew was that I wanted to deal with only this `net` component for now...
and I know it is not only a very foundational part of the project (with huge responsibilities here), but complicated and it carries big debts from the past.

This article is not about how to analyse codebases (which I also did with [CodeScene]), but how to build up a comprehensive understanding of an unfamiliar codebase.

All I had to do again, is count lines of code:
```elixir
servo/components/net$ git ls-files | grep '\.rs' | grep -v tests | xargs wc -l | sort -n
    12 async_runtime.rs
    36 lib.rs
    57 data_loader.rs
    64 hosts.rs
   163 fetch/headers.rs
   183 subresource_integrity.rs
   191 fetch/cors_cache.rs
   206 hsts.rs
   229 cookie.rs
   262 connector.rs
   274 cookie_storage.rs
   277 storage_thread.rs
   439 websocket_loader.rs
   524 decoder.rs
   681 image_cache.rs
   753 resource_thread.rs
   913 http_cache.rs
   970 filemanager_thread.rs
  1006 fetch/methods.rs
  1164 mime_classifier.rs
  2192 http_loader.rs
 10596 total
```

Ten thousand lines of code feels like a lot, but in fact, it is not that horrible. True, the monstrosity files over a thousand lines feel like codesmell.
We also see that there are multiple areas we are tapping into here: threads, caches, parsing, classifying, decoding, etc.

Rust is all about types. And I am not speaking about static typing here, but wrapping values into other types and giving them various functions this way.
Sometimes it is a `struct`, sometimes it is an `enum`... or something else. **Sometimes these could be considered as monads!**

Anyhow, we are not here to talk about type theory. We know which files (aka. modules) are the lightweight ones and which are not.
Now I want to know what types we have and which modules define them.

```rust
servo/components/net$ git grep "enum "
connector.rs:pub enum CACertificates {
cookie_storage.rs:pub enum RemoveCookieError {
data_loader.rs:pub enum DecodeError {
decoder.rs:pub enum Error {

# results are truncated because of the length
```

Right, but I want to know the contents of these enums too:
```rust
servo/components/net$ git grep -A15 -hE "enum (.+) " | sed -n '/enum/,/}/p'
pub enum CACertificates {
    Default,
    Override(RootCertStore),
}
# results are truncated because of the length
```

We also do it with structs:
```rust
servo/components/net$ git grep -E "struct (.+) "
connector.rs:pub struct ServoHttpConnector {
connector.rs:struct CertificateErrorOverrideManagerInternal {
connector.rs:struct TokioExecutor {}
connector.rs:struct CertificateVerificationOverrideVerifier {
cookie.rs:pub struct Cookie {
cookie_storage.rs:pub struct CookieStorage {

# results are truncated because of the length
```

I am also curious where are most of these types defined:
```rust
servo/components/net$ git grep -E "(enum|struct) (.+) " | grep -oE '.+\.rs' | uniq -c | sort -n
      1 cookie.rs
      1 data_loader.rs
      1 storage_thread.rs
      1 subresource_integrity.rs
      1 websocket_loader.rs
      2 cookie_storage.rs
      2 fetch/cors_cache.rs
      2 tests/fetch.rs
      3 hsts.rs
      3 tests/main.rs
      4 fetch/methods.rs
      5 connector.rs
      5 filemanager_thread.rs
      6 resource_thread.rs
      8 mime_classifier.rs
      9 http_cache.rs
     10 image_cache.rs
     11 http_loader.rs
     13 decoder.rs
```

With all this information equipped, we know where to start looking at the code. The smallest files are (excluding `lib.rs` which just includes the modules) 
- `async_runtime.rs`
- `data_loader.rs` (1 type definition)
- `hosts.rs`

The files with most type definitions:
- `decoder.rs` (524 lines)
- `http_loader.rs` (2192 lines)
- `image_cache.rs` (681 lines)

It is clear enough to see in the dark, that `http_loader` is the biggest chunk here to understand, therefore kinda the last item to deal with...
but `decoder` feels like a good direction to start with as it is relatively small and has the most type definitions.

Also, we could check for `impl` blocks and check the `shared/net` component as well. 
(This latter is just around 2600 lines of code, but almost has the same amount of type definitions.)

### Assumptions

Now, at this point, I am not sure what this component wants to achieve, or where are the responsibilities and boundaries.
Sure, we know the modules inside deal with network, storage, cache, and related stuff... but it is a little bit fuzzy. **Bulk.**

#### Assumption #1: shared and base `net` components could be merged

In practice, these two modules have a nice boundary, as only the shared is used in a few other components.
However, to me, it looks like it is not the proper separation.

Having a generic `shared` component feels wrong. Having a `net` component, which has a `shared` module feels much better.
True, this depends more likely on code structuring than architecture.

#### Assumption #2: `net` component could be renamed/reorganized

If a component does this many things, a restructuring may be in order. I would say creating a new component called `io` makes sense.
The current bulk logic should be separated into distinct submodules, something like `io::fs`, `io::cache`, `io::storage`, `io::shared`, etc.

Eventually, when all non-network I/O got to be outsourced to the new component, the leftover could go `io::net`. 

#### Assumption #3: new `io` component could have a shared thread pool

This is somewhat working similarly right now but in a little bit rigid way. My assumption would be, that the base `io` module could own
all concurrency logic and be the only entry point to I/O. Sure, data would travel on channels when needed.

### Documentation

Now we know what to look, where to look at, what we want in the future. All we have to check are the written explanations for the current status.
Fortunately, there are [some docs] regarding this component.

```rust
Structs
    Brotli 🔒- A brotli decoder that reads from a brotli::Decompressor into a BytesMut and emits the results as a Bytes.
    Decoder - A response decompressor over a non-blocking stream of chunks.
    Deflate 🔒- A deflate decoder that reads from a deflate::Decoder into a BytesMut and emits the results as a Bytes.
    Gzip 🔒- A gzip decoder that reads from a libflate::gzip::Decoder into a BytesMut and emits the results as a Bytes.
    Peeked 🔒- A buffering reader that ensures Reads return at least a few bytes.
    Pending 🔒- A future attempt to poll the response body for EOF so we know whether to use gzip or not.
    ReadableChunks - A Readable wrapper over a stream of chunks.

Enums
    DecoderType 🔒
    Error
    Inner 🔒
    PeekedState 🔒
    ReadState 🔒
    StreamState 🔒 
```

It is quite obvious what is happening here. What we have to keep in mind now, is still not implementation details.
But what each module does, and how they connect to each other.

### Entrypoint

Speaking about the connection between the different code parts. We also should understand, what part will call this component,
when it will be called and what data will be passed.

```rust
servo/components$ git grep -E ":?:?net::" | grep -vE "(tests|tokio|std)"
constellation/network_listener.rs:use net::http_loader::{set_default_accept, set_default_accept_language};
constellation/pipeline.rs:use net::image_cache::ImageCacheImpl;
script/body.rs:                // and the corresponding IPC route in `component::net::http_loader`.
script/body.rs:        // Send the chunk to the body transmitter in net::http_loader::obtain_response.
servo/lib.rs:use net::resource_thread::new_resource_threads;
```

This one is straightforward: `constellation` uses our component slightly for tapping into accept headers but heavily relies on
the image cache resource thread. Anyhow, that one will be called from `servo/lib.rs` too at the end of the day.
So that is our entry point!

Technically the component is all about spawning `CoreResourceThreadPool` or `ResourceThreads`.


### Suggestions

A big refactor module by module (a suggested order):
```rust
# not particularly changing path or code
net/async_runtime:HANDLE      -> io::ASYNC_RUNTIME
net/hosts:HOST_TABLE          -> io::net::HOST_TABLE

# moving out (should be implemented elsewhere)
shared/net/quality            -> move (`http::header`)

# `tls` subcomponent
net/connector                 -> io::net::tls

# `compression` subcomponent (based on whatwg/compression spec)
net/decoder                   -> io::net::compression

# `mime` subcomponent (based on whatwg/mimesniff spec)
net/mime_classifier           -> io::net::mime

# `url` subcomponent (based on whatwg/url spec)
shared/net/pub_domains        -> io::net::url
url                           -> io::net::url
net/data_loader               -> io::net::url

# `ws` subcomponent (based on whatwg/websockets spec)
net/websocket_loader          -> io::net::ws

# `fetch` subcomponent (based on whatwg/fetch spec)
net/fetch                     -> io::net::fetch
shared/net/fetch/headers      -> io::net::fetch
shared/net/lib:Fetch*         -> io::net::fetch
shared/net/blob_url_store     -> io::net::fetch
net/hsts                      -> io::net::fetch
net/subresource_integrity     -> io::net::fetch
shared/net/response           -> io::net::fetch
shared/net/request            -> io::net::fetch
#          ^ (worth a cross-check with reqwest)

# `storage/fs/file/cache/thread` components
shared/net/filemanager_thread -> refactor (io::{thread,fs})
shared/net/storage_thread     -> refactor (io::{thread,storage})
net/cookie                    -> io::storage::cookie
net/cookie_storage            -> io::storage::cookie
net/filemanager_thread        -> refactor (io::{thread,fs})
net/http_cache                -> refactor (io::{cache,fs,http})
net/image_cache               -> refactor (io::{cache,fs})
net/resource_thread           -> refactor (io::{thread,_})
net/storage_thread            -> refactor (io::{thread,storage})

# `http` subcomponent
net/http_loader               -> io::net::http
#   ^ (parts of it swapping to/from `fetch`)
```


### Additional benefits

Refactoring the whole thing is a huge effort, no doubt. The question arises, is it really worth it? 
**And the answer in my opinion is a huge yes.**

The refactor not only gives a fresher, more organized look for the code. But people who will absolve it will have huge domain knowledge about it.
These people could easily have a very firm ownership of this part of the engine. In addition, during a refactor like this, the test coverage of these
codes should go up, and the quality and correctness of the documentation is also could reach never-seen altitudes.

If this would be a company project, I would say a weak maybe. There the codes and projects appear and disappear easily in 5-year terms.
But `servo` will be with us for much longer (if not forever), and maintainability has incredible value.



# TODO: suggestions
shared threadpool with priorities
resource thread with lazy loads







[Servo]: https://servo.org
[lfe]: https://linuxfoundation.eu/
[Rust]: https://rust-lang.org
[Servo code]: https://github.com/servo/servo
[CodeScene]: https://codescene.io
[some docs]: https://doc.servo.org/net/index.html
