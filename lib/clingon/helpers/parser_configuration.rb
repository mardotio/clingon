module Clingon
  class ParserConfiguration
    attr_accessor :inputs, :delimiter, :strict
    attr_reader :conf_file, :structure

    def initialize
      @delimiter = '-'
      @strict = true
    end

    def conf_file=(file)
      unless File.exist?(file)
        msg = "Configuration file (#{file}) does not exist"
        raise(Clingon::ConfigurationFileError, msg)
      end
      if File.directory?(file)
        msg = "Configuration file (#{file}) is a directory"
        raise(Clingon::ConfigurationFileError, msg)
      end
      if File.zero?(file)
        msg = "Configuration file (#{file}) is empty"
        raise(Clingon::ConfigurationFileError, msg)
      end
      begin
        yaml_contents = YAML.load_file(file)
      rescue Psych::SyntaxError => e
        raise(Clingon::YAMLSyntaxError, e)
      end
      if yaml_contents.key?(:structure)
        self.structure = yaml_contents[:structure]
      else
        msg = "Configuration file (#{file}) must contain :structure key"
        raise(Clingon::ConfigurationFileError, msg)
      end
      self.strict = yaml_contents[:strict] if yaml_contents.key?(:strict)
      self.delimiter = yaml_contents[:delimiter] if yaml_contents.key?(:delimiter)
    end

    def structure=(struct)
      @structure = StructureChecker.check(struct)
    end
  end
end
