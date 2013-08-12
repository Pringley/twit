require "twit/version"
require "twit/repo"
require "twit/error"

require 'open3'

# This module exposes twit commands as methods.
module Twit

  # Get a {Twit::Repo} representing the repository for the current working
  # directory.
  def self.repo
    Twit::Repo.new
  end

  # Initialize a git repository in a directory. Return a Twit::Repo object
  # representing the new repository.
  #
  # If no argument is supplied, use the working directory.
  def self.init dir = nil
    dir ||= Dir.getwd
    Dir.chdir dir do
      stdout, stderr, status = Open3.capture3 "git init"
      if status != 0
        raise Error, stderr
      end
    end
    Repo.new dir
  end

  # Save a snapshot on the default repo.
  def self.save message
    self.repo.save message
  end

  # PERMANENTLY discard changes to default repo since last save
  def self.discard
    self.repo.discard
  end

end
