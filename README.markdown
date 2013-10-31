# Twit: training wheels for Git

[![Build Status](https://travis-ci.org/Pringley/twit.png)](https://travis-ci.org/Pringley/twit)

Twit is an accessible version-control system based on the widely popular
[Git](http://git-scm.com) program.

## Installation

To install, simply run:

    gem install twit

(On some systems, this may require `sudo`.)

## Usage

Version control allows you to keep track of **changes** to a project over time.

### Example: roll back with `rewind`

Bob is working on an essay for English class. He creates a folder called
`myessay` and wants to track his changes.

First, he needs to turn that folder into a version-controlled **repository**.
This is done with the `init` command:

    cd myessay
    twit init

Then, Bob writes an initial draft of his essay in `myessay/essay.txt`. He can
then take a snapshot of his first draft using:

    twit save

Each time he makes some edits to the paper, he runs `twit save` again.

One day, he decides to restructure the essay entirely. He makes several `save`s
with his big changes, deleting large amounts of text.

The next day he realizes that his restructuring effort was a huge mistake and
wants to recover the way his essay used to be. With version control, you can
roll back to any previous save point you've marked with `save`.

Bob uses `rewind` to go back three `save`s ago:

    twit rewind 3

**Note:** using version control and frequent `save`s has a few benefits over
simply making a bunch of copies of your folder. One such benefit is space --
Twit (and its backend Git) only saves *changes* to your repository rather than
copying the entire thing. If you have a project with big files, this can save a
lot of hard disk space. Also, just typing `twit save` is faster than copying,
pasting, and renaming your new folder with some sort of label so you can find
it later. This encourages you to make more checkpoints, which gives you more
points to roll back to.

### Example: using branches for a computer science class

**Branches** are like bookmarks at different save points. They allow you to
quickly switch between different versions of your repository.

In his computer science class, Bob has a three-part computer lab assignment. In
the first part, he must write a program, and in the second and third parts, he
must modify the program he wrote in two different ways.

Bob creates a folder called `cslab` and initializes it as a repository.

    cd cslab
    twit init

He completes the first part of the assignment. He now uses `saveas` to create a
new branch containing his completed part one code.

    twit saveas part1

He then works on part two. Once that's working, he can create *another* branch:

    twit saveas part2

Now, he has a problem -- the code he wrote for part two is making it really
hard to finish part three! That's okay -- it's easy to switch back to the part
one branch.

    twit open part1

Now the repository is reverted back to the way it was in part one. (The part
two code is still saved in the `part2` branch -- it's just stored elsewhere for
now.)

From the part one code, Bob can finish the thirt part and run

    twit saveas part3

Now there are three branches: `part1`, `part2`, and `part3`. Any of them can be
accessed with `twit open`, so Bob can easily show the professor his work.

## Motivation (written for programmers)

Twit is a wrapper for [Git](http://git-scm.com) that abstracts concepts that
many newcomers find tedious or confusing (at the cost of significant
flexibility).

When explaining version control to newcomers, the benefits are often unclear
amid the complicated rules and syntax of a powerful tool like Git. Twit aims to
provide an *easy and functional* demonstration of the usefulness of a branching
version control system.

For example, you can say that "version control allows you to save snapshots of
your project history." However, in order to do this, you need to understand
Git's two-step stage-then-commit workflow, with all its corner cases regarding
new/deleted/moved files. `git commit -a` ignores new files, `git add .` won't
stage file deletions, etc -- even `git add --all` has to be run from the root
of the working tree.

Instead, Twit exposes a simple command to create a new commit with a snapshot
of the repository:

    twit save

This stages *all* changes (including new files and deletions) and creates a
commit, prompting the user for a commit message if needed.

To create a new branch (and save any changes to the new branch as well):

    twit saveas my_new_branch

If the user forgets to supply the branch argument and just uses `twit saveas`,
the CLI will nicely prompt them for a new branch name.

This quick-and-easy approach allows a new user to get started using version
control right away, without having to learn Git's minutiae.

However, this simple program is **not** meant to replace Git for the power
user. The interface was designed to be user-friendly at the cost of
flexibility.

Git has a staging area for a reason -- atomic commits are important. Using
`twit save` will almost certainly result in commits with batches of changes
mangled together. *That's okay.* Twit isn't for professionals -- it's Git for
your mother to write a book, or for non-coders to add documentation to an open
source project. Best of all, **the repository is still Git underneath**, so
people can transition easily.

If you are a programmer, you should probably just buckle down and [learn
git](http://gitref.org). Instead, Twit serves as an introduction to version
control for users that would probably never learn Git, like writers or
students.

## Command Reference

### `init` -- create a new repository

    twit init

Initialize a new git repository in the current directory.

Similar to: `git init`

### `save` -- commit all new changes to the current branch

    twit save [DESCRIBE_CHANGES]

Take a snapshot of all files in the directory.

Any changes on the working tree will be committed to the current branch.

Similar to: `git add --all && git commit -m <DESCRIBE_CHANGES>`

### `saveas` -- commit all new changes to a new branch

    twit saveas [NEW_BRANCH] [DESCRIBE_CHANGES]

Similar to: `git checkout -b <NEW_BRANCH>` then `twit save`

### `open` -- open another branch

    twit open [BRANCH]

Similar to: `git checkout <branch>`

Note: you can't use `twit open` to checkout a lone commit in detached HEAD
mode.

### `rewind` -- permanently rewind a branch

    twit rewind [AMOUNT]

**Permanently** move a branch back AMOUNT saves.

Similar to: `git reset --hard HEAD~<amount>`

### `discard` -- permanently delete unsaved changes

    twit discard

**Permanently** delete any unsaved changes to the current branch. Be careful!

Similar to: `git reset --hard`

### `list` -- show all branches

    twit list

Similar to: `git branch`

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
