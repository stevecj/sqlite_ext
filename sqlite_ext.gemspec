# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sqlite_ext/version'

Gem::Specification.new do |spec|
  spec.name          = "sqlite_ext"
  spec.version       = SqliteExt::VERSION
  spec.authors       = ["Steve Jorgensen"]
  spec.email         = ["stevej@stevej.name"]

  spec.summary       = "Provides a convenient way of writing functions in Ruby that can " \
                       "be called from within SQLite queries through the sqlite3 gem."
  spec.homepage      = "https://github.com/stevecj/sqlite_ext"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sqlite3"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
end
