require 'clingon/errors'
require 'clingon/version'
require 'clingon/helpers/input_store'
require 'clingon/helpers/structure_checker'
require 'clingon/checks/checks'
require 'clingon/helpers/parser_configuration'
require 'yaml'

class Clingon
  attr_accessor :conf, :store, :reserved

  def initialize
    self.store = InputStore.new
    self.conf = ParserConfiguration.new
  end

  def configure
    yield(self.conf)
    self.reserved = self.conf.structure.inject([]) do |all, current|
      arr = ["#{conf.delimiter * 2}#{current[:name]}"]
      arr << "#{conf.delimiter}#{current[:short_name]}" if current[:short_name]
      all + arr
    end
  end

  def parse
    strict_parse if self.conf.strict
    required_values = get_required
    parse_required(required_values)
    optional_values = get_optional
    parse_optional(optional_values)
  end

  def fetch(value = nil)
    if value
      self.store.fetch(value)
    else
      self.store.inputs
    end
  end

  private
  def strict_parse
    cli_inputs = self.conf.inputs.clone
    cli_inputs.each do |input|
      if input =~ /^#{self.conf.delimiter}{1,2}/ && !reserved?(input)
        raise(ReservedKeywordError.new(received: input, reserved: [/^-{1,2}/]))
      end
    end
  end

  def get_required_value(flag)
    name = "#{self.conf.delimiter * 2}#{flag[:name]}"
    short_name = "#{self.conf.delimiter}#{flag[:short_name]}" if flag[:short_name]
    index = self.conf.inputs.index(short_name) if short_name
    index ||= self.conf.inputs.index(name)
    raise(MissingArgumentError.new(name: name, short_name: short_name)) unless index
    self.conf.inputs[index + 1]
  end

  def get_optional_value(flag)
    empty = flag[:empty]
    name = "#{self.conf.delimiter * 2}#{flag[:name]}"
    short_name = "#{self.conf.delimiter}#{flag[:short_name]}" if flag[:short_name]
    index = self.conf.inputs.index(short_name) if short_name
    index ||= self.conf.inputs.index(name)
    if index && empty
      true
    elsif empty
      false
    elsif index
      self.conf.inputs[index + 1]
    else
      nil
    end
  end

  def get_required
    self.conf.structure.select { |flag| flag[:required] }
  end

  def get_optional
    self.conf.structure.reject { |flag| flag[:required] }
  end

  def reserved?(value)
    self.reserved.include?(value)
  end

  def convert_to_type(value, type)
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

  def parse_required(required_structure)
    required_structure.each do |flag|
      check = flag[:check]
      type = flag[:type]
      allowed_values = flag[:values]
      user_input = get_required_value(flag)
      if reserved?(user_input)
        raise(ReservedKeywordError.new(received: user_input, reserved: reserved))
      end
      if allowed_values
        check_allowed_value(user_input, allowed_values)
      elsif type
        check_against_type(user_input, type)
      elsif check
        check_against_regex(user_input, check)
      end
      self.store.store(flag[:name], user_input)
    end
  end

  def parse_optional(optional_structure)
    optional_structure.each do |flag|
      check = flag[:check]
      type = flag[:type]
      allowed_values = flag[:values]
      empty = flag[:empty]
      user_input = get_optional_value(flag)
      if user_input && !empty
        if reserved?(user_input)
          raise(ReservedKeywordError.new(received: user_input, reserved: reserved))
        end
        if allowed_values
          check_allowed_value(user_input, allowed_values)
        elsif type
          check_against_type(user_input, type)
          user_input = convert_to_type(user_input, type)
        elsif check
          check_against_regex(user_input, check)
        end
      end
      self.store.store(flag[:name], user_input)
    end
  end
end
