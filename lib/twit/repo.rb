require 'open3'
require 'rugged'
require 'twit/error'

module Twit

  # An object to represent a git repository.
  class Repo

    # The root directory of the repository.
    attr_reader :root

    # Takes an optional argument of a Dir object to treat as the repository
    # root. If not, try to detect the root of the current repository.
    #
    # When run without arguments in a directory not part of a git repository,
    # raise {Twit::NotARepositoryError}.
    def initialize root = nil
      if root.nil?
        stdout, stderr, status = Open3.capture3 "git rev-parse --show-toplevel"
        if status != 0
          case stderr
          when /Not a git repository/
            raise NotARepositoryError
          else
            raise Error, stderr
          end
        end
        root = stdout.strip
      end
      @root = root
      @git = Rugged::Repository.new(root)
    end

    # Update the snapshot of the current directory.
    def save message
      raise NothingToCommitError if nothing_to_commit?
      @git.index.add_all
      @git.index.write
      usr = {name: @git.config['user.name'],
             email: @git.config['user.email'],
             time: Time.now}
      opt = {}
      opt[:tree] = @git.index.write_tree
      opt[:author] = usr
      opt[:committer] = usr
      opt[:message] = message
      opt[:parents] = unless @git.empty?
                        begin
                          [@git.head.target].compact
                        rescue Rugged::ReferenceError
                          []
                        end
                      else [] end
      opt[:update_ref] = 'HEAD'
      Rugged::Commit.create(@git, opt)
    end

    # Save the current state of the repository to a new branch.
    def saveas newbranch, message = nil
      message ||= "Create new branch: #{newbranch}"
      begin
        if @git.empty?
          # For an empty repo, we can "create a new branch" by setting HEAD to
          # a symbolic reference to the new branch. Then, the next commit will
          # create that branch (instead of master).
          Rugged::Reference.create(@git, 'HEAD',
               "refs/heads/#{newbranch}", true)
        else
          # For a non-empty repo, we just create a new branch and switch to it.
          branch = @git.create_branch newbranch
          @git.head = branch.canonical_name
        end
      rescue Rugged::ReferenceError => error
        case error.message
        when /is not valid/
          raise InvalidParameter, "#{newbranch} is not a valid branch name"
        when /already exists/
          raise InvalidParameter, "#{newbranch} already exists"
        else
          raise Error, "Internal Rugged error: #{error.message}"
        end
      end

      # Next, save any working changes.
      begin
        save message
      rescue NothingToCommitError
        # New changes are not required for saveas.
      end
    end

    # Return an Array of branches in the repo.
    def list
      Dir.chdir @root do
        cmd = "git branch"
        stdout, stderr, status = Open3.capture3 cmd
        if status != 0
          case stderr
          when /Not a git repository/
            raise NotARepositoryError
          else
            raise Error, stderr
          end
        end
        return stdout.split.map { |s|
          # Remove trailing/leading whitespace and astericks
          s.sub('*', '').strip
        }.reject { |s|
          # Drop elements created due to trailing newline
          s.size == 0
        }
      end
    end

    # Return the current branch.
    def current_branch
      ref = Rugged::Reference.lookup(@git, 'HEAD').resolve
      if not ref.branch?
        raise Error, "Not currently on a branch."
      end
      ref.name.split('/').last
    end

    # Open a branch.
    def open branch
      ref = Rugged::Branch.lookup(@git, branch)
      raise InvalidParameter, "#{branch} is not a branch" if ref.nil?
      @git.head = ref.canonical_name
      @git.reset('HEAD', :hard)
    end

    # Clean the working directory (permanently deletes changes!!!).
    def discard
      # First, add all files to the index. (Otherwise, we won't discard new
      # files.) Then, hard reset to revert to the last saved state.
      @git.index.add_all
      @git.index.write
      @git.reset('HEAD', :hard)
    end

    # Incorperate changes from another branch, but do not commit them.
    #
    # Return true if the merge was successful without conflicts; false if there
    # are conflicts.
    def include other_branch
      Dir.chdir @root do
        cmd = "git merge --no-ff --no-commit \"#{other_branch}\""
        stdout, stderr, status = Open3.capture3 cmd
        if status != 0
          if /Not a git repository/.match stderr
            raise NotARepositoryError
          elsif /Automatic merge failed/.match stdout
            return false
          else
            raise Error, stderr
          end
        end
      end
      return true
    end

    # Reverse of {Twit::Repo#include} -- incorperate changes from the current
    # branch into another.
    def include_into other_branch
      original_branch = current_branch
      open other_branch
      include(original_branch)
    end

    # Return true if there is nothing new to commit.
    def nothing_to_commit?
      Dir.chdir @root do
        cmd = "git status"
        stdout, stderr, status = Open3.capture3 cmd
        if status != 0
          case stderr
          when /Not a git repository/
            raise NotARepositoryError
          else
            raise Error, stderr
          end
        end
        # Check if status indicates nothing to commit
        return /nothing to commit/.match stdout
      end
    end

  end

end
