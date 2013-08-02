require "twit"

describe Twit do

  describe "::repo" do
    it "returns a repo object" do
      repo = Twit.repo
      expect(repo).to be_instance_of(Twit::Repo)
    end
  end

end
