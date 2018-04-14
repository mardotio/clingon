# Clingon

[![Gem](https://img.shields.io/gem/v/clingon.svg?style=flat-square)](https://rubygems.org/gems/clingon)
[![GitHub issues](https://img.shields.io/github/issues/mardotio/clingon.svg?style=flat-square)](https://github.com/mardotio/clingon/issues)
[![Gem](https://img.shields.io/gem/dtv/clingon.svg?style=flat-square)](https://rubygems.org/gems/clingon)

## Overview

The clingon gem can be used to easily parse command line input from a user.
It can also be configured so that you can validate the inputs you receive. This 
gem can be used to parse something like this:

```
--first_name bob --last_name smith --email bob.smith@email.com -h
```

into this:

```ruby
[
  {
    :name => 'first_name',
    :value => 'bob'
  },{
    :name => 'last_name',
    :value => 'smith'
  },{
    :name => 'email',
    :value => 'bob.smith@email.com'
  },{
    :name => 'help',
    :value => true
  }
]
```

## Table of Contents

<!-- TOC -->

- [Clingon](#clingon)
  - [Overview](#overview)
  - [Installation](#installation)
  - [Setup](#setup)
    - [Name](#name)
    - [Short Name](#short-name)
    - [Required](#required)
    - [Empty](#empty)
    - [Type](#type)
    - [Check](#check)
    - [Values](#values)
  - [Use](#use)
    - [Configuration](#configuration)
    - [Parsing](#parsing)
    - [Accessing Values](#accessing-values)
  - [Examples](#examples)

<!-- /TOC -->

## Installation

To install simply use Ruby's gem installer:

```
gem install clingon
```

## Setup

In order to use the library, you must provide a structure that defines all
of the values you expect. This structure is expected to be an array of hashes
containing all the options you want. Each hash can contain any of the following
options:

|Option|Expected Value|Required|
|------|--------------|:------:|
|name|string|*|
|short_name|string||
|required|boolean||
|empty|boolean||
|type|string (see below)||
|check|regex/string||
|values|array||

**All keys in each hash must be ruby symbols**

`values`, `type`, and `check` are all used to validate that the received values
match what you were expecting. The parser will only use one of these settings to
validate an input, so you should only define the of those values per input. If
more than one of these values are defined, the parser will use them in the
following order: `values`, `type`, `check`.

### Name

This value will be used as the long name for the command line flag. This value
must be defined in your structure for any value that you want to parse. This
value should be a `string`.

### Short Name

The value will be used to create a shortened version of the flag. It is an
optional value, and it is recommended that it be a single character if possible,
but there is no limit on length.

### Required

Specifies if the flag must be present. If the flag is not found when parsing,
it will throw an error. This value is optional, but if defined, value must
be either `true` or `false`; defaults to `false`.

### Empty

This can be used if the flag does not require any value and is simply an option
marker (i.e -r for recursive or -h for help). This value is optional, but if
defined, value must be either `true` or `false`; defaults to `false`.

The `empty` flag is used for flags that don't need an additional value. It is
essentially a boolean value (`false` if absent `true` is present). If a value is
required it should not have the `empty` flag. Required values that have and
`empty` flag will simply ignore the `empty` option.

### Type

This option allows you to define what type of value the flag is expecting. If
the received value does not match the expected type an error will be thrown.
Currently supported types are:

|Type|Description|
|----|--------|
|num|Any number, integer or float|
|int|Any integer|
|float|A decimal number|
|bool|`true` or `false`|

Additionally, when the values are parsed, the user input will be converted to
the specified type (int, float, bool). If `num` is specified, input will be
converted to either `float` or `int`. When specified in your structure, the type
must be specified as a string.

### Check

Regular expression that should be used to check the input value against. This
can be a string (it will be converted to a regular expression), or a a regular
expression (i.e. `/^\d+$/`). If the received value does not match the specified
regex, an error will be thrown.

**If using a YAML configuration file, it is recommended that you use single
quotes (`'`) when specifing a regular expression. Not doing so may cause the
YAML parser to interpret some of the charaters as escape charaters.**

### Values

An array of values that are acceptable for the flag. All elements of the array
should be strings since all inputs from a terminal are received by ruby as
strings. If the received value is not a member of the array, an error will be
thown.

## Use

### Configuration

To use the parser, you must first configure the library with your structure and
the inputs you wish to parse. There are four values you can configure.

|Setting|Description|Value|Required|
|-------|-----------|-----|:------:|
|structure|The structure to be used|Array|*|
|inputs|The inputs you need to parse|Array|*|
|delimiter|Delimiter for the flags (defaults to `-`)|String||
|strict|Whether parser should accept inputs that look like flags|Bool||

Optionally, you can use a YAML configuration file to set some or all of these
values (at the minimum, the file should contain the structure). To use this
option, pass a relative or absolute path to a YAML file. The parser expects to
find the same values as the table above as sybols (i.e `:structure`, `:strict`).
The only value that cannot be configured through the file are the inputs. To
use a file to configure the parser, just do:

```ruby
Clingon.configure do |c|
  c.conf_file = 'conf_file.yaml'
end
```

### Parsing

After you have configured the parser, you simply need to call the `parse`
method.

```ruby
Clingon.parse
```

### Accessing Values

The parser has a `fetch` method that allows you to retrieve one or all of the
parsed values. To access the parsed values, simply call the method with the
value you want, or leave the arguments empty if you want to retrive all values.

if you query for a specific value, you must use the `name` that was used in the
configuration structure.

```ruby
# This will return all parsed values as an array of hashes
all_values = Clingon.fetch

# This will return a hash containing the value that was requested, or nil if the
# value was not found
name = Clingon.fetch('name')
```

## Examples

[`structure.yaml`](/examples/structure.yaml) contains a structure in YAML
format. [`example_1.rb`](/examples/example_1.rb) makes use of the YAML file
configuration file. If you are not interested in using a YAML configuration
file, and instead want to define your structure within your script,
[`example_2.rb`](/examples/example_2.rb) defines an inline structure.
