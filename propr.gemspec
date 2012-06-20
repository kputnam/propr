Gem::Specification.new do |s|
  s.name        = "propr"
  s.summary     = "Property-based testing for Ruby (ala QuickCheck)"
  s.homepage    = "https://github.com/kputnam/propr"

  s.version = "0.2.0"
  s.date    = "2012-06-18"
  s.author  = "Kyle Putnam"
  s.email   = "putnam.kyle@gmail.com"

  s.add_dependency "fr", ">= 0.9.1"
  s.files          = Dir["*.md", "Rakefile",
                         "bin/*",
                         "lib/**/*",
                         "doc/**/*.md",
                         "spec/**/*"]
  s.test_files     = Dir["spec/examples/**/*.example"]
  s.has_rdoc       = false
  s.require_path   = "lib"
end
