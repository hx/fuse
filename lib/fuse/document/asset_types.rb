class Fuse::Document::Asset

  class Image < self
    MIME_TYPES = {
        ico: 'image/x-icon'
    }
    def type
      MIME_TYPES[extension.to_sym] || super
    end
  end

  def self.const_missing(name)
    (@anonymous_subclasses ||= {})[name] ||= Class.new(self)
  end

  TYPES = {
      css:    StyleSheet,
      scss:   StyleSheet::Sass,
      sass:   StyleSheet::Sass,
      js:     JavaScript,
      coffee: JavaScript::Coffee,
      jpg:    Image,
      jpeg:   Image,
      png:    Image,
      gif:    Image,
      svg:    Image,
      ico:    Image,
      ttf:    Font,
      woff:   Font,
      eot:    Font,
      otf:    Font,
      xml:    Xml,
      xsl:    Xsl,
      htm:    Html,
      html:   Html
  }
end
