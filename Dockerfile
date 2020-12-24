FROM debian:stretch-slim AS ruby_runtime

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

RUN apt-get update -qq \
 && apt-get install -qy --no-install-recommends ruby ruby-bundler libpq5 file uchardet \
 && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/*

ENV BUNDLE_SILENCE_ROOT_WARNING=1
CMD ["irb"]

# Multi-stage builds
FROM ruby_runtime AS ruby_development

RUN apt-get update -qq \
 && apt-get install -qy --no-install-recommends build-essential zlib1g-dev ruby-dev libpq-dev \
 && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/*

RUN sed -i 's/"Extra file"/&\n  File.unlink File.join(gem_directory, extra)/' /usr/lib/ruby/2.3.0/rubygems/validator.rb
