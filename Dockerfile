FROM ruby:2.3-slim AS ruby_runtime

RUN apt-get update -qq \
 && apt-get install -qy --no-install-recommends libpq5 file \
 && rm -rf /var/lib/apt/lists/* /tmp/*

ENV BUNDLE_APP_CONFIG=.bundle

# Multi-stage builds
FROM ruby:2.3 AS ruby_development

RUN sed -i 's/"Extra file"/&\n  File.unlink File.join(gem_directory, extra)/' /usr/local/lib/ruby/site_ruby/2.3.0/rubygems/validator.rb

ENV BUNDLE_APP_CONFIG=.bundle
