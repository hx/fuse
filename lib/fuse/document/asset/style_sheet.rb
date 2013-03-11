class Fuse::Document::Asset
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
      Fuse.log "SASS: Compressed #{path} from #{original.bytesize} bytes to #{compressed.bytesize} bytes", :success
      compressed
    end
    def type; 'text/css' end
    class Sass < self
      def filter
        original = raw
        compiled = ::Sass.compile original, style: :expanded
        Fuse.log "SASS: Compiled #{path} from #{original.bytesize} bytes to #{compiled.bytesize} bytes", :success
        compiled
      end
    end
  end
end
