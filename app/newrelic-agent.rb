#! /usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require 'aws-sdk'
require "newrelic_plugin"

AWS_SQS_URL = ENV['AWS_SQS_URL']

module WordstreamPythonAssertionErrors

  class Agent < NewRelic::Plugin::Agent::Base

    # NewRelic agent setup
    agent_guid "com.wordstream.python-assertion-errors-from-papertrail"
    agent_version "1.0.1"
    agent_human_labels("Python Assertion Errors from Papertrail") { "Asserts" }

    # kick off a thread to populate the local queue with messages from SQS
    @@local_queue = Queue.new
    Thread.new do
      queue_poller = Aws::SQS::QueuePoller.new(AWS_SQS_URL)

      puts 'set up poller. doing long poll'
      queue_poller.poll do |msg|
        puts 'received data from SQS! ', msg.body
        @@local_queue.push msg.body
      end
    end

    def poll_cycle
      puts "running NewRelic poll cycle"

      # take any messages off the local queue and count them
      count = 0
      while not @@local_queue.empty?
        puts 'found message in local queue. current count: ', count
        _ = @@local_queue.pop
        count += 1
      end

      # send count to newrelic
      report_metric "Assertion errors", "count", count

      puts "completed NewRelic poll cycle"
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
