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

    it "does not raise error on double-initialize" do
      Twit.init @tmpdir
      expect {
        Twit.init @tmpdir
      }.not_to raise_error
    end

  end

  shared_context "stub repo" do
    before do
      @repo = double('repo')
      Twit.stub(:repo) { @repo }
    end
  end

  describe "::save" do
    include_context "stub repo"
    it "passes to default Repo object" do
      message = "my test commit message"
      expect(@repo).to receive(:save).with(message)
      Twit.save message
    end
  end

  describe "::saveas" do
    include_context "stub repo"
    it "passes to default Repo object" do
      branch = "my_branch"
      message = "my test commit message"
      expect(@repo).to receive(:saveas).with(branch, message)
      Twit.saveas branch, message
    end
  end

  describe "::discard" do
    include_context "stub repo"
    it "passes to default Repo object" do
      expect(@repo).to receive(:discard)
      Twit.discard
    end
  end

  describe "::list" do
    include_context "stub repo"
    it "passes to default Repo object" do
      expect(@repo).to receive(:list)
      Twit.list
    end
  end

  describe "::open" do
    include_context "stub repo"
    it "passes to default Repo object" do
      branch = "my_branch"
      expect(@repo).to receive(:open).with(branch)
      Twit.open branch
    end
  end

  describe "::include" do
    include_context "stub repo"
    it "passes to default Repo object" do
      branch = "my_branch"
      expect(@repo).to receive(:include).with(branch)
      Twit.include branch
    end
  end

  describe "::include_into" do
    include_context "stub repo"
    it "passes to default Repo object" do
      branch = "my_branch"
      expect(@repo).to receive(:include_into).with(branch)
      Twit.include_into branch
    end
  end

  describe "::current_branch" do
    include_context "stub repo"
    it "passes to default Repo object" do
      expect(@repo).to receive(:current_branch)
      Twit.current_branch
    end
  end

  describe "::nothing_to_commit?" do
    include_context "stub repo"
    it "passes to default Repo object" do
      expect(@repo).to receive(:'nothing_to_commit?')
      Twit.nothing_to_commit?
    end
  end

  describe "::is_repo?" do
    context "with no repo" do
      before do
        @tmpdir = Dir.mktmpdir
      end
      after do
        FileUtils.remove_entry @tmpdir
      end
      it "returns false on empty directory" do
        expect(Twit.is_repo? @tmpdir).to be_false
      end
      it "detects the current directory" do
        Dir.chdir @tmpdir do
          expect(Twit.is_repo?).to be_false
        end
      end
    end
    context "with a real repo" do
      it "takes a directory as argument" do
        expect(Twit.is_repo? @tmpdir).to be_true
      end
      it "detects the current directory" do
        expect(Twit.is_repo?).to be_true
      end
    end
  end

end
