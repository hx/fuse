# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fuse/version'

Gem::Specification.new do |s|
  s.name              = 'fuse'
  s.version           = Fuse::VERSION
  s.required_ruby_version = '>= 1.9.0'
  s.date              = Date.today.to_s
  s.summary           = 'Fuse HTML, CSS, JavaScript, Fonts and Images into a single file.'
  s.description       = <<-EOF
Portable document authoring. Fuse HTML, JavaScript, CSS, images and fonts into standalone HTML files.
EOF
  s.authors           = ['Neil E. Pearson']
  s.email             = 'neil@helium.net.au'
  s.license           = 'Apache 2.0'
  s.files             = Dir['{bin,lib}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
  s.homepage          = 'https://github.com/hx/fuse'
  s.executables       += Dir['bin/*'].map { |f| File.basename(f) }
  '
    thin              ~> 1.6
    uglifier          ~> 2.6
    nokogiri          ~> 1.6
    coffee-script     ~> 2.3
    sass              ~> 3.4

  '.strip.split(/[\r\n]+/).each { |line| s.add_dependency *(line.strip.split ' ', 2) }
  s.add_development_dependency 'rspec', '~> 2.12'
  s.add_development_dependency 'capybara', '~> 2.0'
end
