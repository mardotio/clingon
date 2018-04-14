require 'clingon'

# This example uses an inline structure definition. If you do not want to use a
# YAML file to setup the parser you can do this instead. Setting strict to
# false it allows the user to input values that start with the delimiter (in
# this case -).

structure = 
  [{
    name: 'first_name',
    short_name: 'n',
    values: [
      'bob',
      'alice',
      'mallory',
    ],
    required: true,
  },{
    name: 'last_name',
    short_name: 'l',
    check: /^\w+$/,
    required: true,
  },{
    name: 'quantity',
    short_name: 'q',
    type: 'int',
  },{
    name: 'file',
    short_name: 'f',
  },{
    name: 'help',
    short_name: 'h',
    empty: true,
  }]

clingon.configure do |c|
  c.structure = structure
  c.inputs = ARGV.clone
  c.strict = false
end

clingon.parse
puts clingon.fetch
