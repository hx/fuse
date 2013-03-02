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
    result.to_html encoding: @options[:encoding]
  end

  def result

    #todo find a way to transform Nokogiri XML to HTML without serializing

    document = if xsl_path
      Nokogiri::HTML(Nokogiri::XSLT(File.read xsl_path).transform(Nokogiri::XML(File.read source_path)).to_html encoding: @options[:encoding])
    else
      Nokogiri::HTML(File.read source_path)
    end

    html = document.css('> html').first
    body = html.css('> body').first
    head = html.css('> head').first || body.add_previous_sibling(Nokogiri::XML::Node.new 'head', document)

    document.title = @options[:title] unless @options[:title].nil?

    [Fuse::Document::Asset::StyleSheet, Fuse::Document::Asset::JavaScript].each do |klass|
      collection = assets.of_type(klass).sort!
      next unless collection.length > 0
      if @options[:embed_assets]
        tag = Nokogiri::XML::Node.new(klass::EMBED_WITH, document)
        raw = collection.map do |asset|
          tag['type'] = asset.type
          (@options[:compress_assets] ? asset.compress : asset.filtered).strip
        end.reject{ |x| x.length == 0 }.join(klass::JOIN_WITH)
        next unless raw.length > 0
        tag.content = raw
        head << tag
      else
        collection.each do |asset|
          data = asset.reference_with
          tag = Nokogiri::XML::Node.new(data[:tag_name], document)
          data[:attributes].each { |k, v| tag[k] = v unless v.nil? }
          head << tag
        end
      end
    end

    #embed images
    if @options[:embed_assets]
      %w|@src @href @style style|.each do |xpath|
        document.xpath('//' + xpath).each do |node|
          assets.of_type(Fuse::Document::Asset::Image).each do |asset|
            node.content = node.content.gsub asset.path.sub(%r`^/`, ''), asset.to_datauri
          end
        end
      end
    end

    document
  end

  def root
    @root ||= File.directory?((opt = @options[:source])) ? opt : File.dirname(opt)
  end

  private

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
