require 'open3'
require 'twit/error'

module Twit
  class Repo

    # Update the snapshot of the current directory.
    def save message
      Dir.chdir @root do
        cmd = "git add --all && git commit -m \"#{message}\""
        stdout, stderr, status = Open3.capture3 cmd
        if status != 0
          raise Error, stderr
        end
      end
    end

  end
end
