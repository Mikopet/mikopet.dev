FROM ruby:3-alpine

RUN apk add --no-cache build-base gcc bash cmake git
RUN gem update --system
RUN gem install bundler jekyll

WORKDIR /site

COPY Gemfile .
RUN bundle install --retry 5 --jobs 20

EXPOSE 4000

CMD [ "bundle", "exec", "jekyll", "serve", "--drafts", "--force_polling", "-H", "0.0.0.0", "-P", "4000", "--livereload" ]
