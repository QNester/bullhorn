RSpec.describe HeyYou do
  it "has a version number" do
    expect(HeyYou::VERSION).not_to be nil
  end

  it "has a config" do
    expect(HeyYou::Config).not_to be nil
  end
end
