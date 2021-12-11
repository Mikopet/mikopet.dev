---
layout: post
title: "Avoid the postvoid unavoidable"
date: 2021-09-19
category: blog
tags: architect infrastructure math
image: https://cdn.mos.cms.futurecdn.net/REbMruWs8PukHAYdZ5XcsK-970-80.jpg
---

Although, the title is an oxymoron... it provides an important thought:

> You want to evade the problems you likely will encounter. That is called precaution.<!--more-->  
> -by myself, again

Let me tell about the background why this post was born. In my native country there is a tradition for creating inadequate infrastructures for almost everything not sparing the IT industry. Especially at the state level where we do fancy apps on a "bread-toaster" and wondering why it dies under a few dozen users.
That is why we need to talk about _reliability_ and _availability_.

This weekend was not different, our statesmans created some pre-election and there was an online voting system involved. Past tense is a justified, for that reason at least: it died as expected.

I take bets at this point. The country has around 8 million voter. Half of them are interested in this kind of voting. I do not think there will be that much attendee, but counting with the usual participation rate, we apply an 70% attendance. With some rounding up we got 3 million voters.
We do not know the request metrics but if we do something like `standard deviation in normal distribution`, we suspect the peak load cannot cross over a few thousand requests simultaneously.
It is because the system shone approximately 4 hours and if we suppose the breakdown was at the top (which is unlikely), that means the last third 80 minutes (`σ-1`) to the peak contains the34% of all voters according to the `empirical rule (68–95–99.7)`. It is not likely, because we would have had more time for voting not just 8 hours at all, but that is indifferent for now.

[image]

Let us say the average user spent around 5 minutes with the whole process (you need to choose between a few candidates) and left. Hence, we can calculate with the 34% of the 3 million users and distribute them equally in the given 80 minutes divided in 5 minutes. One 5 minute block deals with 63750 users. It is not very lifelike if an user does more interaction at the same time, so this throughput is about roughly 200 request/sec.
That is no more than a moderate size webshop's usage on black friday.

## But what can we do?

Well, a lot of opportunities are in line which we could use to serve a high amount of load.
The first rule maybe that we want to reduce the request count, so static contents (like images, scripts, stylesheets) can be served from other resources than the main application.
Usually that is some CDN. The second bastion is to cache the dinamic content as possible.
In case of usual websites, the most of the content can be generated statically and served through the same CDNs or other solutions, but the parts that are not, we can use client-side cache very easily. In this manner the only thing we need to care about on the server-side is the authentication/authorization and the voting.

Here comes the fun part. We usually want to run infrastructures in the cloud, because of the `pay-as-you-go` approach.
> You pay only for the individual services you need, for as long as you use them. Similar to how you pay for utilities like water and electricity. You only pay for the services you consume...

In this special case we want to use some minimal `High Availability` solution just for sure if some servers decide to lay down, and surely with some failover to replace instances what are out of service. So we must use load balancer, and to be honest if we are not making a botch we will configure at least some reasonable autoscaling to match the demand.

At this point, we have an adequate infrastructure to let things happen, but...
... we have an other tradition at home: we do not take responsibility. I do not know why but if there is an other possibility why the solution went awry, we blame that. Not ourselves...

You know the walk, there was rumors, the site was a victom of a `DDoS` attack. Although, this excuse comes up all the time, I do not believe in gossip, only in facts...
Nonetheless, they got a point.

We need to prepare for everything. DDoS mitigation is a complicated matter and needs high proficiency, fortunately we do not need to know the details. We could just buy some CloudFlare subscription or if we want, we can set up a correct solution at our chosen cloud provider.
Generally you want to reject all non-relevant or unessential traffic, especially the malicious ones. 

This is how you begin to design an infrastructure, when you _know_ you will get some high traffic in a short time interval.

There is another aspect of these kind of applications, the security. That is the next pillar which is inevitable to deal with. The legitimacy of the result is a fragile concept and it is mandatory to have invulnerable, inpenetrable system and unalterable operation.
But that is an other discussion.
