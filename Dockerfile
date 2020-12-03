FROM amazonlinux:2 AS ruby_runtime

ENV LANG C.UTF-8

RUN amazon-linux-extras enable ruby2.4 postgresql9.6 \
 && yum install -y ruby ruby-irb rubygems rubygem-json \
  postgresql-libs \
 && yum clean all \
 && rm -rf /var/cache/yum/ /tmp/*
RUN gem install bundler -v '~> 1' -N \
 && gem install rake -v '~> 12' -N \
 && rm -rf ~/.gem/ /tmp/*

ENV BUNDLE_SILENCE_ROOT_WARNING=1

# Multi-stage builds
FROM ruby_runtime AS ruby_development

RUN yum install -y gcc gcc-c++ make patch redhat-rpm-config zlib-devel \
  ruby-devel sqlite-devel postgresql-devel \
 && yum clean all \
 && rm -rf /var/cache/yum/ /tmp/*
RUN sed -i 's/"Extra file"/&\n  File.unlink File.join(gem_directory, extra)/' /usr/share/rubygems/rubygems/validator.rb

CMD ["irb"]
