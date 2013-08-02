module Twit

  # A generic error raised by Twit. (All other errors inherit from this one.)
  class Error < RuntimeError; end

  # Raised when commands are executed in a directory that is not part of a git
  # repository.
  class NotARepositoryError < Error; end

end
