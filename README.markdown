# Twit: training wheels for git

Twit makes [git](http://git-scm.com) easier for beginners.

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

*Not yet implemented.*

### `open` -- open another branch

    twit open [BRANCH]

Equivalent to: `git checkout <branch>`

*Not yet implemented.*

### `include` -- incorperate changes from another branch

    twit include [OTHER_BRANCH]

Incorperate changes from another branch, but do not save them yet. (The user
can resolve any conflicts and then run `twit save` themselves.)

Equivalent to: `git merge --no-ff --no-commit [OTHER_BRANCH]`

*Not yet implemented.*

### `discard` -- permanently delete unsaved changes

    twit discard

**Permanently** delete any unsaved changes to the current branch. Be careful!

Equivalent to: `git reset --hard`

*Not yet implemented.*

### `list` -- show all branches

    twit list

Equivalent to: `git branch`

*Not yet implemented.*

## API

All command-line functions are available for use as a Ruby library as well.

    require 'twit'

    # Create a new repository
    repo = Twit.init

    # Make some changes to the directory
    File.open('foo', 'w') { |f| f.write('bar\n') }

    # Take a snapshot
    Twit.save "Add some foo"

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
