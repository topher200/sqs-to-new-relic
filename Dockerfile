# initial setup
FROM ubuntu:16.04
MAINTAINER Topher <topher200@gmail.com>
RUN echo 'set -o vi' >> /root/.bashrc
WORKDIR /root/sqs-to-new-relic

# install dependencies
RUN apt-get update && apt-get install -y \
    git \
    ruby
RUN gem install bundler

# add app to VM filesystem
ADD app ./
RUN chmod +x newrelic-agent.rb
RUN bundle install --path vendor/bundle

# run our New Relic agent
# RUN ./newrelic-agent.rb