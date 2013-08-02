require "twit/cli"

describe Twit::CLI do

  before do
    @cli = Twit::CLI.new
  end

  describe "init" do
    it "calls Twit.init" do
      Twit.should_receive(:init)
      @cli.invoke :init
    end
  end

end
