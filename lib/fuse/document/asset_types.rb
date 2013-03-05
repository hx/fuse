require 'sass'
require 'coffee-script'
require 'uglifier'

class Fuse::Document::Asset

  module HasDependents
    COMMENT_PATTERN = %r`^\s*(/\*[\s\S]*?\*/|(\s*//.*\s+)+)`
    REQUIRE_PATTERN = %r`^\s*(?:\*|//)=\s+(require|require_glob)\s+(.+?)\s*$`

    def dependents
      ret = Fuse::Document::AssetCollection.new
      local_root = File.dirname(full_path)
      if (comments = raw[COMMENT_PATTERN])
        comments.lines.each do |line|
          if (match = REQUIRE_PATTERN.match(line))
            case match[1]
              when 'require'
                [File.join(local_root, match[2])]
              when 'require_glob'
                Dir[File.join(local_root, match[2])]
              else
                []
            end.map do |p|
              Fuse::Document::Asset.for(p[@root.length..-1], @root)
            end.reject do |p|
              p.nil?
            end.each do |p|
              ret << p
            end
          end
        end
      end
      ret
    end
  end

  class StyleSheet < self
    EMBED_WITH = 'style'
    JOIN_WITH = ''
    MEDIA_PATTERN = /\(([a-z]+(?:,\s*[a-z]+)*)\)\.[a-z]+$/i
    include HasDependents
    def reference_with
      {
          tag_name: 'link',
          attributes: {
              rel: 'stylesheet',
              href: relative_path,
              media: media
          }
      }
    end
    def media
      @media ||= (match = MEDIA_PATTERN.match(path)) && match[1].split(/,\s*/).sort.join(', ')
    end
    def compress
      original = raw
      compressed = ::Sass.compile original, style: :compressed
      Fuse.log "SASS: Compressed #{path} from #{original.length} bytes to #{compressed.length} bytes", :success
      compressed
    end
    def type; 'text/css' end
    class Sass < self
      def filter
        original = raw
        compiled = ::Sass.compile original, style: :expanded
        Fuse.log "SASS: Compiled #{path} from #{original.length} bytes to #{compiled.length} bytes", :success
        compiled
      end
    end
  end

  class JavaScript < self
    EMBED_WITH = 'script'
    JOIN_WITH = ';'
    include HasDependents
    def reference_with
      {
          tag_name: 'script',
          attributes: {
              type: type,
              src: relative_path
          }
      }
    end
    def compress
      original = filtered
      compressed = Uglifier.compile original
      Fuse.log "Uglifier: Compressed #{path} from #{original.length} bytes to #{compressed.length} bytes", :success
      compressed
    end
    def type; 'text/javascript' end
    class Coffee < self
      def filter
        original = raw
        compiled = CoffeeScript.compile original
        Fuse.log "CoffeeScript: Compiled #{path} from #{original.length} bytes to #{compiled.length} bytes", :success
        compiled
      end
    end
  end

  class Image < self
  end

  class Font < self
    CSS_FORMATS = [
        { extension: :woff, format: 'woff' },
        { extension: :ttf,  format: 'truetype' },
        { extension: :otf,  format: 'opentype' }
    ]
    MIME_TYPES = {
        otf: 'application/x-font-opentype',
        ttf: 'application/x-font-truetype',
    }
    VARIANT_PATTERN = %r`([^/]+?)(?:[-_ ](normal|bold|bolder|lighter|[1-9]00))?(?:[-_ ](normal|italic|oblique))?\.[a-z]+$`
    def family; @family ||= variant[:family] end
    def weight; @weight ||= variant[:weight] end
    def style;  @style  ||= variant[:style]  end
    def variant
      @variant ||= begin
        match = VARIANT_PATTERN.match(path)
        {
            family: match[1],
            weight: match[2] || 'normal',
            style:  match[3] || 'normal'
        }
      end
    end
    def face; @face ||= [family, weight, style].join('-') end
    def type
      MIME_TYPES[extension.to_sym] || super
    end
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
