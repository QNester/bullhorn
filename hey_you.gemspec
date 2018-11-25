
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hey_you/version"

Gem::Specification.new do |spec|
  spec.name          = "hey-you"
  spec.version       = HeyYou::VERSION
  spec.authors       = ["Sergey Nesterov"]
  spec.email         = ["qnesterr@gmail.com"]

  spec.summary       = 'Send multichannel notification with one command.'
  spec.description   = 'Send multichannel notifications with one command. ' \
    'Сonvenient storage of notifications texts. Create your own channels.' \
    'Registrate receiver send notifications easy.'
  spec.homepage      = "https://github.com/QNester/hey_you"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fcm", '~> 0.0.2'
  spec.add_runtime_dependency "mail", '~> 2.7'

  spec.add_development_dependency "rake", '~> 10.5'
  spec.add_development_dependency "rspec", '~> 3.7'
  spec.add_development_dependency "webmock", '~> 3.4'
  spec.add_development_dependency "ffaker", '~> 2.9'
end
