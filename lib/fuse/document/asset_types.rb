require 'sass'
require 'coffee-script'
require 'uglifier'

module Fuse
  class Document
    class Asset

      module HasDependents
        COMMENT_PATTERN = %r`^\s*(/\*.*?\*/|(\s*//.*\s+)+)`
        REQUIRE_PATTERN = %r`^\s*(?:\*|//)=\s+(require|require_glob)\s+(.+?)\s*$`

        def dependents
          ret = AssetCollection.new
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
                  Asset.for(p[@root.length..-1], @root)
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
        include HasDependents
        def compress; ::Sass.compile raw, style: :compressed end
        class Sass < self
          def filter; ::Sass.compile raw, style: :expanded end
          def type; 'text/css' end
        end
      end

      class JavaScript < self
        include HasDependents
        def compress; Uglifier.compile filtered end
        class Coffee < self
          def filter; CoffeeScript.compile raw end
          def type; 'text/javascript' end
        end
      end

      class Image < self
      end

      class Font < self
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
          ttf:    Font,
          woff:   Font,
          eot:    Font,
          xml:    Xml,
          xsl:    Xsl,
          htm:    Html,
          html:   Html
      }
    end
  end
end