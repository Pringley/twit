require "twit"

require "tmpdir"

describe Twit do

  describe "::repo" do
    it "returns a repo object" do
      repo = Twit.repo
      expect(repo).to be_instance_of(Twit::Repo)
    end
  end

  describe "::init" do

    before do
      @tmpdir = Dir.mktmpdir
    end

    after do
      FileUtils.remove_entry @tmpdir
    end

    # Check if the current working directory is a git repository.
    def expect_cwd_to_be_repo
      `git status`
      expect($?.exitstatus).to eq(0)
    end

    it "initializes given directory" do
      Twit.init @tmpdir
      Dir.chdir @tmpdir do
        expect_cwd_to_be_repo
      end
    end

    it "initializes the working directory by default" do
      Dir.chdir @tmpdir do
        Twit.init
        expect_cwd_to_be_repo
      end
    end

    it "returns a repo object" do
      repo = Twit.init @tmpdir
      expect(repo).to be_instance_of(Twit::Repo)
    end

  end

end
