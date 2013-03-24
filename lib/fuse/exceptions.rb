class Fuse::Exception < ::RuntimeError
  class SourceUnknown < self
    class TooManySources < self
      attr_reader :option_name, :options
      def initialize(option_name, options)
        @option_name = option_name
        @options = options
      end
    end
    class NotFound < self
      attr_reader :path
      def initialize(path)
        @path = path
      end
      def message; "Couldn't find '#{path}'." end
    end
    def message; 'Couldn\'t determine source document. Please specify one with --source.' end
  end
  class XslMissing < self
    def message
      'Couldn\'t locate an XSL stylesheet to transform the source document. Please specify one with --xsl.'
    end
  end
  class CircularDependency < self
    def initialize(offender, dependent)
      @offender, @dependent = offender, dependent
    end
    def message
      "Found circular dependency as #{@offender.path} depends upon #{@dependent.path}"
    end
  end
  def message; end
end
