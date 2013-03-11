class Fuse::Document::Asset
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
      Fuse.log "Uglifier: Compressed #{path} from #{original.bytesize} bytes to #{compressed.bytesize} bytes", :success
      compressed
    end
    def type; 'text/javascript' end
    class Coffee < self
      def filter
        original = raw
        compiled = CoffeeScript.compile original
        Fuse.log "CoffeeScript: Compiled #{path} from #{original.bytesize} bytes to #{compiled.bytesize} bytes", :success
        compiled
      end
    end
  end

end
