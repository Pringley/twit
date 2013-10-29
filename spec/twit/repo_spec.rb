require 'tmpdir'
require 'tempfile'
require 'securerandom'

require 'twit'
require 'spec_helper'

describe Twit::Repo do

  describe "#new" do

    before do
      @tmpdir = Dir.mktmpdir

      # OS X uses /private/tmp and /tmp interchangably, so straight comparison
      # of directories sometimes fails. Instead, detect this particular
      # directory by creating a file in an end checking for its existence.
      @file_in_dir = Tempfile.new '.detect', @tmpdir
    end

    def expect_root dir
      path = Pathname.new File.join(dir, File.basename(@file_in_dir))
      expect(path).to be_exist
    end

    after do
      FileUtils.remove_entry @tmpdir
    end

    it "works with a directory argument" do
      `git init #{@tmpdir}` # only works on initialized repo
      repo = Twit::Repo.new @tmpdir
      expect_root repo.root
    end

    it "detects git root while at root (no args)" do
      Dir.chdir @tmpdir do
        `git init`
        repo = Twit::Repo.new
        expect_root repo.root
      end
    end

    it "detects git root while in subdirectory (no args)" do
      Dir.chdir @tmpdir do
        `git init`
        Dir.mkdir 'subdir'
        Dir.chdir 'subdir' do
          repo = Twit::Repo.new
          expect_root repo.root
        end
      end
    end

    it "raises an error when not in a repo (no args)" do
      Dir.chdir @tmpdir do
        expect {
          repo = Twit::Repo.new
        }.to raise_error Twit::NotARepositoryError
      end
    end

  end

  describe "#save" do

    include_context "temp repo"

    context "files in working tree" do
      before do
        3.times do |i|
          File.open("file#{i}.txt", 'w') { |f| f.write("file#{i} contents\n") }
        end
      end
      it "commits the entire working tree" do
        @repo.save "created three files"
        expect(`git status`).to include('working directory clean')
      end
      it "makes a commit" do
        msg = "commit msg #{SecureRandom.hex(4)}"
        @repo.save msg
        expect(`git log`).to include(msg)
      end
    end

    it "raises error in new repository" do
      expect {
        @repo.save "trying to save"
      }.to raise_error(Twit::NothingToCommitError)
    end

    it "raises error with nothing to commit" do
      # First, make sure there's at least one commit on the log.
      File.open("foo", 'w') { |f| f.write("bar\n") }
      `git add foo && git commit -m "add foo"`

      # Now there should be nothing more to commit
      expect {
        @repo.save "trying to save"
      }.to raise_error(Twit::NothingToCommitError)
    end

  end

  describe "#list" do

    include_context "temp repo"

    it "should return an Array of branches" do
      # Make sure there's at least one commit on master.
      File.open("foo", 'w') { |f| f.write("bar\n") }

      @repo.save "Initial commit"

      branches = ['all', 'your', 'branch', 'are',
                   'belong', 'to', 'us']
      branches.each do |branch|
        `git branch #{branch}`
      end

      expect(@repo.list).to match_array(branches + ['master'])
    end

    it "should return empty on an empty repo" do
      expect(@repo.list).to match_array([])
    end

  end
  
  describe "#discard" do

    include_context "temp repo"

    context "with one commit and dirty working tree" do

      before do
        # Make sure there's at least one commit on master.
        File.open("foo", 'w') { |f| f.write("bar\n") }
        @repo.save "Initial commit"

        # Pollute the working tree with spam
        File.open("spam", 'w') { |f| f.write("eggs\n") }
      end

      it "should clean the working tree" do
        @repo.discard
        expect(`git status`).to include('working directory clean')
      end

      it "should delete the spam file" do
        @repo.discard
        expect(Pathname "spam").not_to exist
      end

    end

  end

  describe "#saveas" do
    
    include_context "temp repo"

    context "files in working tree" do
      before do
        3.times do |i|
          File.open("file#{i}.txt", 'w') { |f| f.write("file#{i} contents\n") }
        end
      end
      it "commits the entire working tree" do
        @repo.saveas "newbranch"
        expect(`git status`).to include('working directory clean')
      end
      it "makes a commit" do
        msg = "commit msg #{SecureRandom.hex(4)}"
        @repo.saveas "newbranch", msg
        expect(`git log`).to include(msg)
      end
      it "creates a new branch" do
        new_branch = "branch-#{SecureRandom.hex(4)}"
        @repo.saveas new_branch
        current_branch = `git rev-parse --abbrev-ref HEAD`.strip
        expect(current_branch).to eq(new_branch)
      end
    end

    it "raises an error with an invalid branch name" do
      expect {
        @repo.saveas "new branch"
      }.to raise_error(Twit::InvalidParameter)
    end

    it "raises an error when the branch already exists" do
      branch = "my_branch"
      File.open("foo", 'w') { |f| f.write("bar\n") }
      @repo.saveas branch
      expect {
        @repo.saveas branch
      }.to raise_error(Twit::InvalidParameter)
    end

    it "does not raise error in new repository" do
      expect {
        @repo.saveas "newbranch"
      }.not_to raise_error
    end

    it "does not raise error with nothing to commit" do
      # First, make sure there's at least one commit on the log.
      File.open("foo", 'w') { |f| f.write("bar\n") }
      `git add foo && git commit -m "add foo"`

      # Now there should be nothing more to commit, but no error should be
      # raised.
      expect {
        @repo.saveas "newbranch"
      }.not_to raise_error
    end

  end

  describe "#current_branch" do

    include_context "temp repo"

    it "returns the name of the current branch" do
      new_branch = "branch-#{SecureRandom.hex(4)}"
      File.open("foo", 'w') { |f| f.write("bar\n") }
      @repo.saveas new_branch
      expect(@repo.current_branch).to eq(new_branch)
    end

  end

  describe "#nothing_to_commit?" do
    include_context "temp repo"
    it "returns true in fresh repo" do
      expect(@repo.nothing_to_commit?).to be_true
    end
    it "returns false with file in working tree" do
      File.open("foo", 'w') { |f| f.write("bar\n") }
      expect(@repo.nothing_to_commit?).to be_false
    end
    it "returns true after one commit" do
      File.open("foo", 'w') { |f| f.write("bar\n") }
      @repo.save "commit"
      expect(@repo.nothing_to_commit?).to be_true
    end
  end

  describe "#open" do

    include_context "temp repo"

    it "opens a branch" do
      new_branch1 = "branch-#{SecureRandom.hex(4)}"
      File.open("foo", 'w') { |f| f.write("bar\n") }
      @repo.saveas new_branch1

      new_branch2 = "branch-#{SecureRandom.hex(4)}"
      @repo.saveas new_branch2

      @repo.open new_branch1
      current_branch = `git rev-parse --abbrev-ref HEAD`.strip
      expect(current_branch).to eq(new_branch1)
    end

    it "raises error when branch does not exist" do
      expect {
        @repo.open "spam"
      }.to raise_error(Twit::InvalidParameter)
    end

  end

end
