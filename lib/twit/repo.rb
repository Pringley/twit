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
        begin
          root = Rugged::Repository.discover(Dir.getwd)
        rescue Rugged::RepositoryError
          raise NotARepositoryError
        end
      end
      @git = Rugged::Repository.new(root)
      @root = @git.workdir
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
      @git.branches.map(&:name)
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

    # Create a new branch at the specified commit id.
    def rewind new_branch, commit_id
      raise UnsavedChanges unless nothing_to_commit?
      # Set HEAD to the specified commit.
      Rugged::Reference.create(@git, 'HEAD', commit_id, true)
      # Reset to that commit.
      discard
      # Create a new branch pointing the old commit.
      saveas(new_branch)
    end

    # Return true if there is nothing new to commit.
    def nothing_to_commit?
      @git.status do |file, status|
        return false unless status.empty?
      end
      return true
    end

  end

end
