$LOAD_PATH.push(File.expand_path('../lib', __FILE__))
require 'clingon/version'

Gem::Specification.new do |s|
  s.name             = 'clingon'
  s.version          = Clingon::VERSION.dup
  s.date             = '2018-04-06'
  s.summary          = 'Flexible command line parser.'
  s.description      =
    'Clingon is a parser for command line inputs. It can help you parse flags,
    and options for your script, as well as convert user inputs to specific ruby
    types. With clingon you can forget about dealing with user inputs, and focus
    on adding functionality to your scripts.'
  s.authors          = ['Mario Lopez']
  s.email            = 'lopezrobles.mario@gmail.com'
  s.files            = `git ls-files lib/`.split("\n")
  s.extra_rdoc_files = ['README.md']
  s.homepage         =
    'https://github.com/mardotio/clingon'
  s.license          = 'MIT'
end
