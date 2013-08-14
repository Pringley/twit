require 'thor'
require 'twit'

module Twit

  # Automatically-built command-line interface (using Thor).
  class CLI < Thor
    include Thor::Actions

    desc "init", "Create an empty repository in the current directory"
    # Pass method to Twit module
    def init
      Twit.init
    end

    desc "save <DESCRIBE_CHANGES>", "Take a snapshot of all files"
    # Pass method to default repo
    def save message = nil
      if Twit.nothing_to_commit?
        say "No new edits to save"
        return
      end
      while message.nil? or message.strip == ""
        message = ask "Please supply a message describing your changes:"
      end
      Twit.save message
    end

    desc "discard", "PERMANTENTLY delete all changes since last save"
    # Pass method to default repo
    def discard
      Twit.discard
    end

  end

end
