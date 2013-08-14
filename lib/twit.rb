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
  #
  # If init is called on a directory that is already part of a repository,
  # simply do nothing.
  def self.init dir = nil
    dir ||= Dir.getwd

    if is_repo? dir
      return
    end

    Dir.chdir dir do
      stdout, stderr, status = Open3.capture3 "git init"
      if status != 0
        raise Error, stderr
      end
    end
    Repo.new dir
  end

  # Check if a given directory is a git repository.
  #
  # If no argument is supplied, use the working directory.
  def self.is_repo? dir = nil
    dir ||= Dir.getwd
    Dir.chdir dir do
      stdout, stderr, status = Open3.capture3 "git status"
      if status != 0
        if /Not a git repository/.match stderr
          return false
        else
          raise Error, stderr
        end
      end
      return true
    end
  end

  # See {Twit::Repo#save}.
  def self.save message
    self.repo.save message
  end

  # See {Twit::Repo#saveas}.
  def self.saveas branch, message = nil
    self.repo.saveas branch, message
  end

  # See {Twit::Repo#discard}. (WARNING: PERMANENTLY DESTROYS DATA!)
  def self.discard
    self.repo.discard
  end

  # See {Twit::Repo#open}.
  def self.open branch
    self.repo.open branch
  end

  # See {Twit::Repo#include}.
  def self.include branch
    self.repo.include branch
  end

  # See {Twit::Repo#include_into}.
  def self.include_into branch
    self.repo.include_into branch
  end

  # See {Twit::Repo#list}.
  def self.list
    self.repo.list
  end

  # See {Twit::Repo#current_branch}.
  def self.current_branch
    self.repo.current_branch
  end

  # See {Twit::Repo#nothing_to_commit?}.
  def self.nothing_to_commit?
    self.repo.nothing_to_commit?
  end

end
