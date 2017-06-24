# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twilreapi/active_call_router/unicef_io/version'

Gem::Specification.new do |spec|
  spec.name          = "twilreapi-active_call_router-unicef_io"
  spec.version       = Twilreapi::ActiveCallRouter::UnicefIO::VERSION
  spec.authors       = ["David Wilkie"]
  spec.email         = ["dwilkie@gmail.com"]

  spec.summary       = %q{Call routing for somleng.unicef.io}
  spec.homepage      = "https://github.com/dwilkie/twilreapi-active_call_router-unicef_io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "twilreapi-active_call_router"
  spec.add_dependency "torasup", "~> 0.1.1"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
