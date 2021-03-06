# frozen_string_literal: true

require 'thor'
require 'open3'

require 'git_topic/version'
require 'git_topic/commands/add'
require 'git_topic/commands/delete'
require 'git_topic/commands/edit'
require 'git_topic/commands/list'
require 'git_topic/commands/show'
require 'git_topic/commands/start'
require 'git_topic/commands/publish'

module GitTopic
  # CLI command entry point
  class Cli < Thor
    default_command :list

    desc 'list', 'Show managed topics'
    option :version, aliases: 'v', desc: 'Show version'
    option :all, aliases: 'a', desc: 'Show all information'
    option :edit, aliases: 'e', desc: 'Edit current topic description'
    def list
      # Show version if -v specified
      version && return if options[:version]
      # Edit topic if -e specified
      edit && return if options[:edit]

      command = GitTopic::Commands::List.new options
      command.execute
    end

    desc 'edit [branch_name]', 'Edit topic description'
    def edit(branch_name = nil)
      command = GitTopic::Commands::Edit.new branch_name
      command.execute
    end

    desc 'show [branch_name]', 'Show topic description'
    def show(branch_name = nil)
      command = GitTopic::Commands::Show.new branch_name
      command.execute
    end

    desc 'version', 'Show version'
    def version
      puts GitTopic::VERSION
      true
    end

    desc 'add topic_name summary', 'Remember topic'
    def add(topic_name, summary)
      command = GitTopic::Commands::Add.new topic_name, summary
      command.execute
    end

    desc 'delete topic_name', 'Delete topic'
    def delete(topic_name)
      command = GitTopic::Commands::Delete.new topic_name
      command.execute
    end

    desc 'start topic_name', 'Transfer topic_name to branch to implement code'
    def start(topic_name)
      command = GitTopic::Commands::Start.new topic_name
      command.execute
    end

    # rubocop:disable Metrics/LineLength
    desc 'publish repo base branch_name', 'Create pull request using branch description'
    # rubocop:enable Metrics/LineLength
    def publish(repo, base, branch_name)
      client = Octokit::Client.new(netrc: true)
      command = GitTopic::Commands::Publish.new client, repo, branch_name, base
      command.execute
    end
  end
end
