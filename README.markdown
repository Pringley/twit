# Twit: simplified git wrapper

Twit makes [git](http://git-scm.com) easier for beginners.

## Installation

Currently, this gem must be installed from source.

## Usage

### `init` -- create a new repository

    twit init

This initializes a new git repository in the current directory.

## API

All command-line functions are available for use as a Ruby library as well.

    require 'twit'

    # Create a new repository
    Twit.init

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
