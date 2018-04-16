class Clingon
  class ConfigurationFileError < StandardError
  end

  class YAMLSyntaxError < StandardError
  end

  class MatchError < StandardError
    attr_reader :expected, :received
    def initialize(payload)
      @expected = payload[:expected]
      @received = payload[:received]
      msg = "Value #{received} does not match #{expected}"
      super(msg)
    end
  end

  class MissingArgumentError < StandardError
    attr_reader :name, :short_name
    def initialize(payload)
      @name = payload[:name]
      @short_name = payload[:short_name]
      name_arr = [name]
      name_arr << short_name if short_name
      msg = "Missing required input #{name_arr.join('/')}"
      super(msg)
    end
  end

  class UnexpectedValueError < StandardError
    attr_reader :expected, :received
    def initialize(payload)
      @expected = payload[:expected]
      @received = payload[:received]
      msg = "Received #{received}, expected one of (#{expected.join(', ')})"
      super(msg)
    end
  end

  class UnexpectedTypeError < StandardError
    attr_reader :received
    def initialize(payload)
      @received = payload[:received]
      msg = "Type #{received} is not valid"
      super(msg)
    end
  end

  class TypeMatchError < StandardError
    attr_reader :expected, :received
    def initialize(payload)
      @expected = payload[:expected]
      @received = payload[:received]
      msg = "Received #{received}, expected type #{expected}"
      super(msg)
    end
  end

  class ReservedKeywordError < StandardError
    attr_reader :received, :reserved
    def initialize(payload)
      @received = payload[:received]
      @reserved = payload[:reserved]
      msg = "Value #{received} is a reserved keyword"
      super(msg)
    end
  end
end
