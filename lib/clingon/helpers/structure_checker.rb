module StructureChecker
  def self.check(structure)
    raise('Structure must be an array') unless structure.instance_of?(Array)
    StructureChecker.verify_contents(structure)
    structure
  end

  def self.verify_contents(structure)
    structure.each do |el|
      raise('Each element of structure must contain name key') unless el[:name]
      if el[:type]
        valid = [
          'int',
          'float',
          'num',
          'bool'
        ]
        unless valid.include?(el[:type])
          raise("Valid types are: #{valid.join(', ')}")
        end
      end
    end
  end
end
