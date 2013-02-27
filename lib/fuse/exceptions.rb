module Fuse
  class Exception < ::Exception
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
      end
    end
    class XslMissing; end
  end
end
