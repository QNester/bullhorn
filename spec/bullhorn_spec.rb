RSpec.describe Bullhorn do
  it "has a version number" do
    expect(Bullhorn::VERSION).not_to be nil
  end

  it "has a config" do
    expect(Bullhorn::Config).not_to be nil
  end
end
