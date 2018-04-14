class InputStore
  attr_reader :inputs
  def initialize
    @inputs = []
  end

  def store(name, value)
    @inputs << {
      name: name,
      value: value
    }
  end

  def fetch(value)
    inputs.inject(nil) do |val, current|
      if current[:name] == value
        current
      else
        val
      end
    end
  end
end
