require 'sass'
require 'coffee-script'
require 'uglifier'

class Fuse::Document::Asset

  class Image < self
  end

  class Xml < self
  end

  class Xsl < self
  end

  class Html < self
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
