require 'tmpdir'
require 'twit'

shared_context "temp repo" do
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
end
