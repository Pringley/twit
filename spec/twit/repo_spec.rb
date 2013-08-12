require 'tmpdir'
require 'tempfile'
require 'securerandom'

require 'twit'

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

    before do
      @tmpdir = Dir.mktmpdir
      @repo = Twit.init @tmpdir
      @oldwd = Dir.getwd
      Dir.chdir @tmpdir
    end

    after do
      Dir.chdir @oldwd
      FileUtils.remove_entry @tmpdir
    end

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

end
