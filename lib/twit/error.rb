module Twit

  # A generic error raised by Twit. (All other errors inherit from this one.)
  class Error < RuntimeError; end

  # Raised when commands are executed in a directory that is not part of a git
  # repository.
  class NotARepositoryError < Error; end

  # Raised when trying to commit nothing.
  class NothingToCommitError < Error; end

  # Raised when trying to operate on a repository with unsaved changes.
  class UnsavedChanges < Error; end

  # Raised when a command receives an invalid parameter.
  class InvalidParameter < Error; end

end
