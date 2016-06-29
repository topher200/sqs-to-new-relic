#! /usr/bin/env ruby

require "bundler/setup"
require "logger"
require "rubygems"

require 'aws-sdk'
require "newrelic_plugin"

AWS_SQS_URL = ENV['AWS_SQS_URL']

STDOUT.sync = true

module WordstreamPythonAssertionErrors

  class Agent < NewRelic::Plugin::Agent::Base
    @@logger = Logger.new(STDOUT)
    @@logger.level = Logger::DEBUG

    # NewRelic agent setup
    agent_guid "com.wordstream.python-assertion-errors-from-papertrail"
    agent_version "1.0.1"
    agent_human_labels("Python Assertion Errors from Papertrail") { "Asserts" }

    # kick off a thread to populate the local queue with messages from SQS
    @@local_queue = Queue.new
    Thread.new do
      queue_poller = Aws::SQS::QueuePoller.new(AWS_SQS_URL)

      @@logger.info 'set up poller. doing long poll'
      queue_poller.poll do |msg|
        @@logger.info 'received data from SQS!'
        @@local_queue.push msg.body
      end
    end

    def poll_cycle
      @@logger.debug "running NewRelic poll cycle"

      # take any messages off the local queue and count them
      count = 0
      while not @@local_queue.empty?
        @@logger.info 'found message in local queue. current count: %s' % count
        _ = @@local_queue.pop
        count += 1
      end

      # send count to newrelic
      @@logger.debug "Sending count of %s to New Relic" % count
      report_metric "Assertions", "asserts", count

      @@logger.debug "completed NewRelic poll cycle"
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
