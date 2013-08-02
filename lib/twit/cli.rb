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

  end

end
