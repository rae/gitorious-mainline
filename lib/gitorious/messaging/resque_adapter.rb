# encoding: utf-8
#--
#   Copyright (C) 2011-2014 Gitorious AS
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
require "resque"
require 'resque/plugins/job_stats'

# Resque backed implementation of the Gitorious messaging API. For use with
# lib/gitorious/messaging
module Gitorious::Messaging::ResqueAdapter
  module Publisher
    QUEUES = {
      # Maps queue => processor class (see app/processors)
      "GitoriousDestroySshKey" => "DestroySshKey",
      "GitoriousMergeRequestBackend" => "MergeRequestGitBackend",
      "GitoriousMergeRequestCreation" => "MergeRequest",
      "GitoriousMergeRequestVersionDeletion" => "MergeRequestVersion",
      "GitoriousEmailNotifications" => "MessageForwarding",
      "GitoriousNewSshKey" => "NewSshKey",
      "GitoriousPush" => "Push",
      "GitoriousRepositoryCloning" => "RepositoryCloning",
      "GitoriousProjectRepositoryCreation" => "ProjectRepositoryCreation",
      "GitoriousTrackingRepositoryCreation" => "TrackingRepositoryCreation",
      "GitoriousRepositoryDeletion" => "RepositoryDeletion",
      "GitoriousPostReceiveWebHook" => "Service",
      "GitoriousWikiRepositoryCreation" => "WikiRepositoryCreation",
      "GitoriousEmailEventSubscribers" => "EmailEventSubscribers"
    }

    # Locate the correct class to pick queue from
    #
    def queue(queue)
      @queues ||= {}
      queue_class_name = "#{QUEUES[queue.to_s.sub(/\/queue\//, "")]}Processor"
      @queues[queue] ||= ResqueQueue.new(queue, queue_class_name)
    end

    def do_publish(queue, message)
      queue(queue).publish(message)
    end
  end

  module Consumer
    def self.included(klass)
      klass.extend(self) if klass != Gitorious::Messaging::Consumer
    end

    def self.extended(mod)
      mod.extend(Resque::Plugins::JobStats)
    end

    def self.extended(mod)
      mod.extend(Resque::Plugins::JobStats)
    end

    def consumes(queue, options = {})
      @queue = queue.sub(/\/queue\//, "")
    end

    def perform(message)
      self.new.consume(message)
    end
  end

  class ResqueQueue
    attr_reader :queue, :processor

    def initialize(queue, processor)
      @queue = queue
      @processor = processor
    end

    def publish(payload)
      Resque.push(queue, :class => processor, :args => [payload])
    end
  end
end

Resque.logger = Gitorious::Messaging.logger
