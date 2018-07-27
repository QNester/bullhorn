RSpec.describe Horn do
  it "has a version number" do
    expect(Horn::VERSION).not_to be nil
  end

  it "has a config" do
    expect(Horn::Config).not_to be nil
  end
end
