#!/bin/bash

docker run -p 8080:4000 -v $(pwd):/site bretfisher/jekyll-serve