require "twit/version"
require "twit/repo"
require "twit/init"
require "twit/error"

# This module exposes twit commands as methods.
module Twit

  # Get a {Twit::Repo} representing the repository for the current working
  # directory.
  def self.repo
    Twit::Repo.new
  end

end
