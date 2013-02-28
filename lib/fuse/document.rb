require 'nokogiri'

class Fuse::Document

  attr_reader :source_path, :xsl_path

  def initialize(options)
    source = (@options = options)[:source]
    raise Fuse::Exception::SourceUnknown if source.nil?
    raise Fuse::Exception::SourceUnknown::NotFound.new(source) unless File.exists?(source)
    @source_path = expect_one(potential_sources, :source, Fuse::Exception::SourceUnknown)
    @xsl_path = expect_one(potential_xsl, :xsl, Fuse::Exception::XslMissing) if source_xml?
  end

  def to_s
    result.to_s
  end

  def result
    document = Nokogiri::HTML(if xsl_path
      Nokogiri::XSLT(File.read xsl_path).transform(Nokogiri::XML(File.read source_path))
    else
      File.read source_path
    end)

    html = document.css('> html').first
    body = html.css('> body').first
    head = html.css('> head').first || body.add_previous_sibling(Nokogiri::XML::Node.new 'head', document)
    title = head.css('> title').first || head.add_child(Nokogiri::XML::Node.new 'title', document)

    title.content = @options[:title] unless @options[:title].nil?

    document
  end

  private

    def root
      @root ||= File.directory?((opt = @options[:source])) ? opt : File.dirname(opt)
    end

    def source_xml?
      source_path.match(/\.xml$/i)
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
