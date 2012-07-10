Gem::Specification.new do |s|
  s.name          = 'documenty-rails'
  s.version       = '0.1.0'
  s.date          = '2012-07-10'
  s.license       = "MIT"
  s.summary       = "Produce Documenty API documentation from your Rails controllers"
  s.description   = "Produce Documenty API documentation from your Rails controllers"
  s.authors       = ["Emil Ahlbäck"]
  s.email         = 'e.ahlback@gmail.com'
  s.files         = `git ls-files -- lib/*`.split("\n")
  s.require_paths = ["lib/documenty-rails", "lib/"]
  s.homepage      = 'https://github.com/pushly/documenty-rails'
end