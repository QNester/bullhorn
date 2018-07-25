RSpec.shared_examples :singleton do
  describe 'must be singleton' do
    it 'have #instance method and return instance' do
      expect(described_class.instance).to be_instance_of(described_class)
    end

    it 'new is private method' do
      expect { described_class.new }.to raise_error(NoMethodError)
    end
  end
end

RSpec.shared_examples :have_accessors do |*names|
  include_examples :have_readers, *names
  include_examples :have_writers, *names
end

RSpec.shared_examples :have_readers do |*names|
  names.each do |name|
    it "have :#{name} reader" do
      expect(described_class).respond_to?(name)
    end
  end
end

RSpec.shared_examples :have_writers do |*names|
  names.each do |name|
    it "have :#{name} writer" do
      expect(described_class).respond_to?("#{name}=")
    end
  end
end