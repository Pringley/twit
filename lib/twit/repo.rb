require 'open3'
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
    end

    # Update the snapshot of the current directory.
    def save message
      Dir.chdir @root do
        cmd = "git add --all && git commit -m \"#{message}\""
        stdout, stderr, status = Open3.capture3 cmd
        if status != 0
          if /nothing to commit/.match stdout
            raise NothingToCommitError
          else
            raise Error, stderr
          end
        end
      end
    end

    # Save the current state of the repository to a new branch.
    def saveas newbranch, message = nil
      message ||= "Create new branch: #{newbranch}"
      # First, create the new branch and switch to it.
      Dir.chdir @root do
        cmd = "git checkout -b \"#{newbranch}\""
        stdout, stderr, status = Open3.capture3 cmd
        if status != 0
          case stderr
          when /not a valid branch name/
            raise InvalidParameter, "#{newbranch} is not a valid branch name"
          else
            raise Error, stderr
          end
        end
      end
      # Next, save any working changes.
      begin
        Twit.save message
      rescue NothingToCommitError
        # New changes are not required for saveas.
      end
    end

    # Return an Array of branches in the repo.
    def list
      Dir.chdir @root do
        `git branch`.split.map { |s|
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
      Dir.chdir @root do
        cmd = "git rev-parse --abbrev-ref HEAD"
        stdout, stderr, status = Open3.capture3 cmd
        if status != 0
          case stderr
          when /unknown revision/
            raise Error, "could not determine branch of repo with no commits"
          else
            raise Error, stderr
          end
        end
        return stdout.strip
      end
    end

    # Clean the working directory (permanently deletes changes!!!).
    def discard
      Dir.chdir @root do
        # First, add all files to the index. (Otherwise, we won't discard new files.)
        `git add --all`
        # Next, hard reset to revert to the last saved state.
        `git reset --hard`
      end
    end

  end

end
