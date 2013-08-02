# Twit: simplified git wrapper

Twit makes [git](http://git-scm.com) easier for beginners.

## Installation

To install, simply run:

    gem install twit

(On some systems, this may require `sudo`.)

## Usage

### `init` -- create a new repository

    twit init

Initialize a new git repository in the current directory.

### `save` -- take a snapshot of all files

    twit save <DESCRIBE_CHANGES>

Take a snapshot of all files in the directory.

Any changes on the working tree will be committed to the current branch.

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
