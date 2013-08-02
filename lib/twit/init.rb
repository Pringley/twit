require 'open3'
require 'twit/error'

module Twit

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
  end

end
