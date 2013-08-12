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
    it "calls Twit.save" do
      message = "my test commit message"
      Twit.should_receive(:save).with(message)
      @cli.invoke :save, [message]
    end
    it "asks for commit message" do
      $stderr.should_receive(:puts).with /message/
      expect {
        @cli.invoke :save
      }.to raise_error SystemExit
    end
  end

  describe "discard" do
    it "calls Twit.discard" do
      Twit.should_receive(:discard)
      @cli.invoke :discard
    end
  end

end
