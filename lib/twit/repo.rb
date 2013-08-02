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
    # raise Twit::NotARepositoryError.
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
  end

end
