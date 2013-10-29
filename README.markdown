# Twit: training wheels for Git

Twit is a wrapper for [Git](http://git-scm.com) that abstracts concepts that
many newcomers find tedious or confusing.

When explaining version control to newcomers, the benefits are often unclear
amid the complicated rules and syntax of a powerful tool like Git. Twit aims to
provide an *easy and functional* demonstration of the usefulness of a branching
version control system.

For example, you can say that "version control allows you to save snapshots of
your project history." However, in order to do this, you need to understand
Git's two-step stage-then-commit workflow, with all its corner cases regarding
new/deleted/moved files.

Instead, Twit exposes a simple command to create a new commit with a snapshot
of the repository:

    twit save

This stages any changes (including new files and deletions) and creates a
commit, prompting the user for a commit message if needed.

To create a new branch (and save any changes to the new branch as well):

    twit saveas my_new_branch

This quick-and-easy approach allows a new user to get started using version
control right away, without having to learn Git's minutiae.

However, this simple program is **not** meant to replace Git for the power
user. The interface was designed to be user-friendly at the cost of
flexibility. If you are a programmer, you should probably just buckle down and
[learn git](http://gitref.org). Instead, Twit serves as an introduction to
version control for users that would probably never learn Git, like writers or
students.

## Installation

To install, simply run:

    gem install twit

(On some systems, this may require `sudo`.)

## Usage

### `init` -- create a new repository

    twit init

Initialize a new git repository in the current directory.

Equivalent to: `git init`

### `save` -- commit all new changes to the current branch

    twit save [DESCRIBE_CHANGES]

Take a snapshot of all files in the directory.

Any changes on the working tree will be committed to the current branch.

Equivalent to: `git add --all && git commit -m <DESCRIBE_CHANGES>`

### `saveas` -- commit all new changes to a new branch

    twit saveas [NEW_BRANCH] [DESCRIBE_CHANGES]

Equivalent to: `git checkout -b <NEW_BRANCH>` then `twit save`

### `open` -- open another branch

    twit open [BRANCH]

Equivalent to: `git checkout <branch>`

### `rewind` -- permanently rewind a branch

    twit rewind [AMOUNT]

**Permanently** move a branch back AMOUNT saves.

Equivalent to: `git reset --hard HEAD~<amount>`

### `discard` -- permanently delete unsaved changes

    twit discard

**Permanently** delete any unsaved changes to the current branch. Be careful!

Equivalent to: `git reset --hard`

### `list` -- show all branches

    twit list

Equivalent to: `git branch`

## API

All command-line functions are available for use as a Ruby library as well.

    require 'twit'

    # Create a new repository
    repo = Twit.init

    # Make some changes to the directory
    File.open('foo', 'w') { |f| f.write('bar\n') }

    # Take a snapshot
    Twit.save "Add some foo"

    # Create a new branch
    Twit.saveas "feature-branch"

## Development

### Setup

Clone the repository.

Install dependencies with:

    bundle install --binstubs

### Testing

Run the tests with:

    bin/rspec

### Documentation

Generate the docs with

    bin/yard

They will appear in the `./doc` folder.
