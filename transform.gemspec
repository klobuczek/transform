# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "transform/version"

Gem::Specification.new do |s|
  s.name        = "transform"
  s.version     = Transform::VERSION
  s.authors     = ["Heinrich Klobuczek"]
  s.email       = ["heinrich@mail.com"]
  s.homepage    = ""
  s.summary     = %q{Data transformation tool}
  s.description = %q{Transforms csv data using basic set operations}

  s.rubyforge_project = "transform"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  #s.add_runtime_dependency "fastercsv"
end
