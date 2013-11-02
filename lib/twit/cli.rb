require 'thor'
require 'twit'
require 'twit/gui'

module Twit

  # Automatically-built command-line interface (using Thor).
  class CLI < Thor
    include Thor::Actions

    desc "init", "Create an empty repository in the current directory"
    # See {Twit::init}
    def init
      begin
        if Twit.is_repo?
          say "You are already in a repository! (Root directory: #{Twit.repo.root})"
          return
        end
        Twit.init
      rescue Error => e
        say "Error: #{e.message}"
      end
    end

    desc "save [DESCRIBE_CHANGES]", "Take a snapshot of all files"
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

    desc "saveas [NEW_BRANCH] [DESCRIBE_CHANGES]", "Save snapshot to new branch"
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
            say "Cannot saveas to existing branch. Try a git merge!"
          else
            say "Error: #{e.message}"
          end
        end
      rescue Error => e
        say "Error: #{e.message}"
      end
    end

    desc "open [BRANCH]", "Open a branch"
    # See {Twit::Repo#open}.
    def open branch = nil
      while branch.nil? || branch.strip == ""
        branch = ask "Please enter the name of the branch to open:"
      end
      begin
        Twit.open branch
      rescue Error => e
        say "Error: #{e.message}"
      else
        say "Opened #{branch}."
      end
    end

    desc "list", "Display a list of branches"
    # See {Twit::Repo#list} and {Twit::Repo#current_branch}
    def list
      begin
        @current = Twit.current_branch
        @others = Twit.list.reject { |b| b == @current }
      rescue Error => e
        say "Error: #{e.message}"
        return
      end
      say "Current branch: #{@current}"
      say "Other branches:"
      @others.each do |branch|
        say "- #{branch}"
      end
    end

    desc "include", "Deprecated after v0.0.2"
    # Deprecated: use git merge instead.
    def include other_branch = nil
      say "This function has been deprecated."
      say "Use git merge instead!"
    end

    desc "include_into", "Deprecated after v0.0.2"
    # Deprecated: use git merge instead.
    def include_into other_branch = nil
      say "This function has been deprecated."
      say "Use git merge instead!"
    end

    desc "rewind", "PERMANTENTLY rewind branch to a previous commit"
    # See {Twit::Repo#rewind}.
    def rewind amount
      begin
        unless Twit.nothing_to_commit?
          return if no? "You have unsaved changes to your branch. Proceed?"
        end
        say "This branch will be rewound by #{amount} save points."
        if yes? "Would you like to save a copy of these last #{amount} points?"
          oldbranch = Twit.current_branch
          newbranch = ask "Enter name for the copy branch:"
          Twit.saveas newbranch
          Twit.open oldbranch
        elsif no? "These #{amount} changes may be lost forever! Are you sure?"
          return
        end
        Twit.rewind amount.to_i
      rescue Error => e
        say "Error: #{e.message}"
      end
    end

    desc "discard", "PERMANTENTLY delete all changes since last save"
    # See {Twit::Repo#discard}.
    def discard
      begin
        say "All changes since last save will be reverted."
        if yes? "Would you like to copy the changes in a different branch instead?"
          oldbranch = Twit.current_branch
          newbranch = ask "Enter name for the copy branch:"
          Twit.saveas newbranch
          Twit.open oldbranch
          return
        elsif no? "These changes will be lost forever! Are you sure?"
          return
        end
        Twit.discard
      rescue Error => e
        say "Error: #{e.message}"
      end
    end

    desc "gui", "Start Twit's graphical user interface"
    # See {Twit::GUI}.
    def gui
      Twit::GUI.main
    end

  end

end
