require 'thor'
require 'twit'

module Twit
  class CLI < Thor

    desc "init", "Create an empty repository in the current directory"
    def init
      Twit.init
    end

  end
end
