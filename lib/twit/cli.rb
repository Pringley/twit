require 'thor'
require 'twit'

module Twit

  # Automatically-built command-line interface (using Thor).
  class CLI < Thor
    include Thor::Actions

    desc "init", "Create an empty repository in the current directory"
    # See {Twit::init}
    def init
      begin
        Twit.init
      rescue Error => e
        say "Error: #{e.message}"
      end
    end

    desc "save <DESCRIBE_CHANGES>", "Take a snapshot of all files"
    # See {Twit::Repo#save}.
    def save message = nil
      begin
        if Twit.nothing_to_commit?
          say "No new edits to save"
          return
        end
        while message.nil? || message.strip == ""
          message = ask "Please supply a message describing your changes:"
        end
        Twit.save message
      rescue Error => e
        say "Error: #{e.message}"
      end
    end

    desc "saveas <NEW_BRANCH> <DESCRIBE_CHANGES>", "Save snapshot to new branch"
    # See {Twit::Repo#saveas}.
    def saveas branch = nil, message = nil
      while branch.nil? || branch.strip == ""
        branch = ask "Please supply the name for your new branch:"
      end
      begin
        if (not Twit.nothing_to_commit?) && message.nil?
          message = ask "Please supply a message describing your changes:"
        end
        begin
          Twit.saveas branch, message
        rescue InvalidParameter => e
          if /already exists/.match e.message
            say "Cannot saveas to existing branch. See \"twit help include_into\""
          else
            say "Error: #{e.message}"
          end
        end
      rescue Error => e
        say "Error: #{e.message}"
      end
    end

    desc "discard", "PERMANTENTLY delete all changes since last save"
    # See {Twit::Repo#discard}.
    def discard
      begin
        Twit.discard
      rescue Error => e
        say "Error: #{e.message}"
      end
    end

  end

end
