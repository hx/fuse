require File.expand_path('../lib/fuse', __FILE__)

Gem::Specification.new do |s|
  s.name              = 'Fuse'
  s.version           = Fuse::VERSION
  s.date              = Date.today.to_s
  s.summary           = 'Fuse HTML, CSS, JavaScript, Fonts and Images into a single file.'
  s.description       = ''
  s.authors           = ['Neil E. Pearson']
  s.email             = 'neil@helium.net.au'
  s.files             = Dir['{bin,lib}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
  s.homepage          = 'https://github.com/hx/fuse'
  s.executables       += Dir['bin/*'].map { |f| File.basename(f) }
  '
    thin              ~> 1.5
    uglifier          ~> 1.3
    nokogiri          ~> 1.5.6
    coffee-script     ~> 2.2
    sass              ~> 3.2.5

  '.strip.split(/[\r\n]+/).each { |line| s.add_dependency *(line.strip.split ' ', 2) }
  s.add_development_dependency 'rspec', '~> 2.12.2'
end
