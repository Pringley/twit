require 'thor'
require 'twit'

module Twit

  # Automatically-built command-line interface (using Thor).
  class CLI < Thor

    desc "init", "Create an empty repository in the current directory"
    # Pass method to Twit module
    def init
      Twit.init
    end

    desc "save <DESCRIBE_CHANGES>", "Take a snapshot of all files"
    # Pass method to default repo
    def save message = nil
      if message.nil?
        $stderr.puts "Please supply a message describing your changes.\n e.g.   twit save \"Update the README\""
        exit false
      end
      begin
        Twit.repo.save message
      rescue NothingToCommitError
        puts "No new edits to save"
      end
    end

    desc "discard", "PERMANTENTLY delete all changes since last save"
    # Pass method to default repo
    def discard
      Twit.repo.discard
    end

  end

end
