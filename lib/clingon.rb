require 'clingon/errors'
require 'clingon/version'
require 'clingon/helpers/input_store'
require 'clingon/helpers/structure_checker'
require 'clingon/checks/checks'
require 'clingon/helpers/parser_configuration'
require 'yaml'

module Clingon
  class << self
    attr_accessor :conf, :store, :reserved
  end

  def self.configure
    self.store ||= InputStore.new
    self.conf ||= ParserConfiguration.new
    yield(conf)
    self.reserved = conf.structure.inject([]) do |all, current|
      arr = ["#{conf.delimiter * 2}#{current[:name]}"]
      arr << "#{conf.delimiter}#{current[:short_name]}" if current[:short_name]
      all + arr
    end
  end

  def self.fetch(value = nil)
    if value
      store.fetch(value)
    else
      store.inputs
    end
  end

  def self.strict_parse
    cli_inputs = conf.inputs.clone
    cli_inputs.each do |input|
      if input =~ /^#{conf.delimiter}{1,2}/ && !Clingon.reserved?(input)
        raise(ReservedKeywordError.new(received: input, reserved: [/^-{1,2}/]))
      end
    end
  end

  def self.parse
    Clingon.strict_parse if conf.strict
    required_values = Clingon.get_required
    Clingon.parse_required(required_values)
    optional_values = Clingon.get_optional
    Clingon.parse_optional(optional_values)
  end

  def self.get_required_value(flag)
    name = "#{conf.delimiter * 2}#{flag[:name]}"
    short_name = "#{conf.delimiter}#{flag[:short_name]}" if flag[:short_name]
    index = conf.inputs.index(short_name) if short_name
    index ||= conf.inputs.index(name)
    raise(MissingArgumentError.new(name: name, short_name: short_name)) unless index
    conf.inputs[index + 1]
  end

  def self.get_optional_value(flag)
    empty = flag[:empty]
    name = "#{conf.delimiter * 2}#{flag[:name]}"
    short_name = "#{conf.delimiter}#{flag[:short_name]}" if flag[:short_name]
    index = conf.inputs.index(short_name) if short_name
    index ||= conf.inputs.index(name)
    if index && empty
      true
    elsif empty
      false
    elsif index
      conf.inputs[index + 1]
    else
      nil
    end
  end

  def self.get_required
    conf.structure.select { |flag| flag[:required] }
  end

  def self.get_optional
    conf.structure.reject { |flag| flag[:required] }
  end

  def self.reserved?(value)
    reserved.include?(value)
  end

  def self.convert_to_type(value, type)
    value_to_convert = value.to_s
    case type
    when 'int'
      value_to_convert.to_i
    when 'float'
      value_to_convert.to_f
    when 'num'
      if value_to_convert =~ /^\d+$/
        value_to_convert.to_i
      else
        value_to_convert.to_f
      end
    when 'bool'
      value_to_convert == 'true'
    else
      value_to_convert
    end
  end

  def self.parse_required(required_structure)
    required_structure.each do |flag|
      check = flag[:check]
      type = flag[:type]
      allowed_values = flag[:values]
      user_input = Clingon.get_required_value(flag)
      if Clingon.reserved?(user_input)
        raise(ReservedKeywordError.new(received: user_input, reserved: reserved))
      end
      if allowed_values
        Clingon.check_allowed_value(user_input, allowed_values)
      elsif type
        Clingon.check_against_type(user_input, type)
      elsif check
        Clingon.check_against_regex(user_input, check)
      end
      store.store(flag[:name], user_input)
    end
  end

  def self.parse_optional(optional_structure)
    optional_structure.each do |flag|
      check = flag[:check]
      type = flag[:type]
      allowed_values = flag[:values]
      empty = flag[:empty]
      user_input = Clingon.get_optional_value(flag)
      if user_input && !empty
        if Clingon.reserved?(user_input)
          raise(ReservedKeywordError.new(received: user_input, reserved: reserved))
        end
        if allowed_values
          Clingon.check_allowed_value(user_input, allowed_values)
        elsif type
          Clingon.check_against_type(user_input, type)
          user_input = Clingon.convert_to_type(user_input, type)
        elsif check
          Clingon.check_against_regex(user_input, check)
        end
      end
      store.store(flag[:name], user_input)
    end
  end
end
