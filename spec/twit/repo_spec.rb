require 'tmpdir'
require 'tempfile'

require 'twit/repo'
require 'twit/error'

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
end
