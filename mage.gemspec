# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mage/version'

Gem::Specification.new do |spec|
  spec.name          = "mage"
  spec.version       = Mage::VERSION
  spec.authors       = ["Viacheslav Mefodin"]
  spec.email         = ["mefodin.v@gmailcom"]

  spec.summary       = %q{Rails wizard model creation}
  spec.description   = %q{This gem allows model to have state, and based on that
    create wizard with step by step validations}
  spec.homepage      = "https://github.com/effect305/mage"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "db"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
