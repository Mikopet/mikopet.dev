#!/bin/bash

rm -rf _site/* .jekyll*/**/* .sass*/**/*
docker run -p 8080:4000 -v $(pwd):/site bretfisher/jekyll-serve