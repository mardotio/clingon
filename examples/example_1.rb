require 'clingon'

# This example uses a YAML configuration file to setup the structure for the
# parser. If you're using a file to configure the parser you can store all
# settings in the file (structure, strict, delimiter), but the only one that is
# required is the structure.

Clingon.configure do |c|
  c.conf_file = File.join(__dir__, 'structure.yaml')
  c.inputs = ARGV.clone
end

Clingon.parse
puts Clingon.fetch
