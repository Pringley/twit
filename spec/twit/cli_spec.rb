require "twit/cli"

describe Twit::CLI do

  before do
    @cli = Twit::CLI.new

    # Mock out Twit library to avoid accidentally clobbering anything during
    # testing.
    stub_const("Twit", double('Twit'))
  end

  describe "init" do
    it "calls Twit.init" do
      Twit.should_receive(:init)
      @cli.invoke :init
    end
  end

  describe "save" do
    it "calls Twit.repo.save" do
      message = "my test commit message"
      repo = double('repo')

      # Expected call is `Twit.repo.save message`
      repo.should_receive(:save).with(message)
      Twit.should_receive(:repo).and_return(repo)

      @cli.invoke :save, [message]
    end
    it "asks for commit message" do
      $stderr.should_receive(:puts).with /message/
      expect {
        @cli.invoke :save
      }.to raise_error SystemExit
    end
  end

end
