#! /usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require 'aws-sdk'
require "newrelic_plugin"

AWS_SQS_URL = ENV['AWS_SQS_URL']

module WordstreamPythonAssertionErrors

  class Agent < NewRelic::Plugin::Agent::Base

    # NewReliic agent setup
    agent_guid "com.wordstream.python-assertion-errors-from-papertrail"
    agent_version "1.0.1"
    agent_config_options :hertz
    agent_human_labels("Example Agent") { "Synthetic example data" }

    queue_poller = Aws::SQS::QueuePoller.new(AWS_SQS_URL)

    def poll_cycle
      puts "running poll"
      queue_poller.poll do |msg|
        puts msg.body
      end
      puts "completed poll"
    end

  end

  #
  # Register this agent with the component. The module must contain at least
  # three classes - a PollCycle, a Metric and an Agent class, as defined above.
  #
  NewRelic::Plugin::Setup.install_agent :pythonAssertionErrors, WordstreamPythonAssertionErrors

  #
  # Launch the agent; this never returns.
  #
  NewRelic::Plugin::Run.setup_and_run

end
