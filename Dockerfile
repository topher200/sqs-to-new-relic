# initial setup
FROM ubuntu:16.04
MAINTAINER Topher <topher200@gmail.com>
RUN echo 'set -o vi' >> /root/.bashrc

# install dependencies
RUN apt-get update && apt-get install -y \
    git \
    ruby
RUN gem install \
    aws-sdk:2 \
    bundler

# pull down New Relic repo
RUN git clone https://github.com/newrelic-platform/newrelic_example_plugin /root/sqs-to-new-relic
WORKDIR /root/sqs-to-new-relic
RUN git checkout tags/release/1.0.1
RUN bundle install --path vendor/bundle

# set up environment
ADD newrelic-plugin-config.yml config/newrelic_plugin.yml
ADD newrelic-agent.rb newrelic-agent.rb
RUN chmod +x newrelic-agent.rb
ADD env.sh env.sh
RUN source env.sh

# run our New Relic agent
RUN ./newrelic-agent.rb