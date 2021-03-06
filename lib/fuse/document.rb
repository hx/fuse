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
    ret = result.to_html encoding: @options[:encoding], indent: 0
    ret.gsub!(/(\s)\s+/, '\\1') unless @options[:preserve_white]
    ret
  end

  def result

    document = if xsl_path
      Nokogiri::XSLT(File.read xsl_path).transform(Nokogiri(File.read source_path))
    else
      Nokogiri::HTML(File.read source_path)
    end

    while (html = document.css('> html').first).nil?
      document = Nokogiri::HTML(document.to_html encoding: @options[:encoding])
    end
    body = html.css('> body').first
    head = html.css('> head').first || body.add_previous_sibling(Nokogiri::XML::Node.new 'head', document)

    unless @options[:title].nil?
      title = head.css('> title').first || head.add_child(Nokogiri::XML::Node.new('title', document))
      title.children = Nokogiri::XML::Text.new(@options[:title], document)
    end

    #add favicon
    assets.of_type(Fuse::Document::Asset::Image).select{ |a| a.path.match %r`\bfavicon\.\w+$` }.each do |asset|
      head << link = Nokogiri::XML::Node.new('link', document)
      link['rel'] = 'shortcut icon'
      link['href'] = asset.relative_path
    end

    #attach scripts
    scripts = assets.of_type(Fuse::Document::Asset::JavaScript).sort!
    head << tag_for_collection(scripts, document) unless scripts.empty?

    #attach stylesheets
    style_sheets = assets.of_type(Fuse::Document::Asset::StyleSheet)
    style_sheets.group_by(&:conditional_signature).each_value do |conditional_collection|
      conditional_collection.group_by(&:media).each do |media, media_collection|
        media_collection.sort!
        tag = tag_for_collection(media_collection, document)
        tag['media'] = media unless media.nil? || media.empty? || Nokogiri::XML::NodeSet === tag
        head << Nokogiri::HTML.fragment(media_collection.first.conditional.wrap(tag.to_html(encoding: @options[:encoding])), @options[:encoding])
      end
    end

    #create font stylesheet
    font_css = ''
    fonts = {}
    assets.of_type(Fuse::Document::Asset::Font).each do |asset|
      (fonts[asset.face] ||= {})[asset.extension.to_sym] = asset
    end
    if fonts.length > 0
      fonts.values.each do |formats|
        first = formats.values.first
        font_css << '@font-face{'
        font_css << first.variant.map{ |k, v| 'font-%s: "%s";' % [k, v] }.join
        font_css << 'src: url("%s");'    % formats[:eot].relative_path if formats[:eot] && !@options[:embed_assets]
        css_formats = []
        Fuse::Document::Asset::Font::CSS_FORMATS.each do |css_format|
          css_formats << 'url("%s") format("%s")' % [
              formats[css_format[:extension]].relative_path,
              css_format[:format]
          ] if formats[css_format[:extension]]
        end
        font_css << 'src: %s;' % css_formats.join(', ') if css_formats.any?
        font_css << '}'
      end
    end
    unless font_css.empty?
      style_node = head.add_child(Nokogiri::XML::Node.new 'style', document)
      style_node.content = font_css + style_node.content
    end

    #embed images and fonts
    if @options[:embed_assets]
      %w|@src @href @style style|.each do |xpath|
        document.xpath('//' + xpath).each do |node|
          assets.of_type(Fuse::Document::Asset::Image, Fuse::Document::Asset::Font).each do |asset|
            node.content = node.content.gsub asset.relative_path, asset.to_datauri
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
      Dir[File.join(option_value || root, "**/*.{#{extensions.join(',')}}")].select{ |f| File.size? f }
    end

    def expect_one(list, option, missing_exception)
      raise missing_exception if list.empty?
      raise Fuse::Exception::SourceUnknown::TooManySources.new(option, list) if list.length > 1
      list.first
    end

    def assets
      @assets ||= Asset[root]
    end

    def tag_for_collection(collection, document)
      return if collection.empty?
      klass = collection.first.class
      if @options[:embed_assets]
        tag = Nokogiri::XML::Node.new(klass::EMBED_WITH, document)
        raw = collection.map do |asset|
          tag['type'] = asset.type
          (@options[:compress_assets] ? asset.compress : asset.filtered).strip
        end.reject{ |x| x.length == 0 }.join(klass::JOIN_WITH)
        return unless raw.length > 0
        tag.content = raw
        tag
      else
        Nokogiri::XML::NodeSet.new(document, collection.map do |asset|
          data = asset.reference_with
          tag = Nokogiri::XML::Node.new(data[:tag_name], document)
          data[:attributes].each { |k, v| tag[k] = v unless v.nil? }
          tag
        end)
      end
    end
end
