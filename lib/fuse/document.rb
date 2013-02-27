require 'nokogiri'

module Fuse
  class Document

    def initialize(options)
      @options = options
    end

    def to_s
      File.read source_path
    end

    def source_path
      @source_path ||= expect_one(potential_sources, :source, Fuse::Exception::SourceUnknown)
    end

    def xsl_path
      @xsl_path ||= (source_path.match(/\.xml$/i)) && expect_one(potential_xsl, :xsl, Fuse::Exception::XslMissing)
    end

    private

      def root
        opt = @options[:source]
        @root ||= if File.directory?(opt)
          opt
        elsif File.file?(opt)
          File.dirname opt
        else
          File.dirname source_path
        end
      end

      def potential_xsl
        @potential_xsl ||= potentials(:xsl, %w(xsl))
      end

      def potential_sources
        @potential_docs ||= begin
          extensions = %w|html htm|
          extensions << 'xml' if potential_xsl.any?
          potentials(:source, extensions)
        end
      end

      def potentials(option, extensions)
        if (option_value = @options[option])
          raise Fuse::Exception::SourceUnknown::NotFound.new(option_value) unless File.exists?(option_value)
          return [option_value] unless File.directory? option_value
        end
        Dir[File.join(option_value || root, "**/*.{#{extensions.join(',')}}")]
      end

      def expect_one(list, option, missing_exception)
        raise missing_exception if list.empty?
        raise Fuse::Exception::SourceUnknown::TooManySources.new(option, list) if list.length > 1
        list.first
      end

      def assets
        @assets ||= Asset[root]
      end
  end
end
