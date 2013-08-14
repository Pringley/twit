require "twit/cli"

describe Twit::CLI do

  before do
    @cli = Twit::CLI.new

    # Mock out Twit library to avoid accidentally clobbering anything during
    # testing.
    stub_const("Twit", double('Twit'))
  end

  describe "init" do
    context "is not repo" do
      before do
        Twit.stub(:'is_repo?') { false }
      end
      it "calls Twit.init" do
        expect(Twit).to receive(:init)
        @cli.invoke :init
      end
    end
  end

  describe "save" do
    context "need to commit" do
      before do
        Twit.stub(:'nothing_to_commit?') { false }
      end
      it "calls Twit.save" do
        message = "my test commit message"
        expect(Twit).to receive(:save).with(message)
        @cli.invoke :save, [message]
      end
    end
  end

  describe "saveas" do
    it "calls Twit.saveas" do
      Twit.stub(:'nothing_to_commit?') { false }
      branch = "my_branch"
      message = "my test commit message"
      expect(Twit).to receive(:saveas).with(branch, message)
      @cli.invoke :saveas, [branch, message]
    end
  end

  describe "discard" do
    it "calls Twit.discard" do
      expect(Twit).to receive(:discard)
      @cli.invoke :discard
    end
  end

end
