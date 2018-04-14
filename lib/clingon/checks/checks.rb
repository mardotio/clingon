require 'clingon/checks/type_regex'

module Clingon
  def self.check_against_type(value, type)
    case type
    when 'int'
      check = Clingon::INT.dup
    when 'float'
      check = Clingon::FLOAT.dup
    when 'num'
      check = Clingon::NUM.dup
    when 'bool'
      check = Clingon::BOOL.dup
    else
      raise(UnexpectedTypeError.new(received: type))
    end

    value_to_check = value.to_s

    return if value_to_check =~ check
    raise(TypeMatchError.new(expected: type, received: value))
  end

  def self.check_against_regex(value, check)
    regex_check = Regexp.new(check)
    return if value =~ regex_check
    raise(MatchError.new(expected: regex_check, received: value))
  end

  def self.check_allowed_value(value, allowed)
    return if allowed.index(value)
    raise(UnexpectedValueError.new(expected: allowed, received: value))
  end
end
