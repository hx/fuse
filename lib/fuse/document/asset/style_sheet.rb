class Fuse::Document::Asset
  class StyleSheet < self

    EMBED_WITH = 'style'
    JOIN_WITH = ''
    MEDIA_PATTERN = /\(([a-z]+(?:,\s*[a-z]+)*)\)(?:\.[a-z]+$|\s*\()/i

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

    def conditional
      @conditional ||= Conditional.new self
    end

    def conditional_signature
      conditional.signature
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

    class Conditional

      CONDITIONAL_PATTERN = /\((!|[lg]te?\s+)?ie(\s*\d+)?\)(?:\.[a-z]+$|\s*\()/i

      attr_reader :comparison, :version

      def initialize(style_sheet)
        match = CONDITIONAL_PATTERN.match(style_sheet.path)
        return unless match
        @comparison = (match[1] || '').strip.downcase
        @version = match[2].strip.to_i unless match[2].nil?
      end

      def wrap(content)
        if comparison == '!'
          "<!--[if !IE]> -->#{content}<!-- <![endif]-->"
        elsif comparison
          "<!--[if #{signature}]>#{content}<![endif]-->"
        else
          content
        end
      end

      def signature
        @signature ||= begin
          ret = (comparison.nil? || comparison.empty?) ? 'IE' : comparison + ' IE'
          ret << ' ' + version.to_s if version
        end
      end

    end
  end
end
