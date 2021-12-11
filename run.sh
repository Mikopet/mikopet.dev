#!/bin/bash

rm -rf _site/* .jekyll*/**/* .sass*/**/*
docker build -t jekyll .
#docker run -it -v $(pwd):/site jekyll bundle update
docker run -it -p 4000:4000 -v $(pwd):/site jekyll
