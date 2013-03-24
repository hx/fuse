module Fuse::Document::Asset::HasDependents

  COMMENT_PATTERN = %r`^\s*(/\*[\s\S]*?\*/|(\s*//.*\s+)+)`
  REQUIRE_PATTERN = %r`^\s*(?:\*|//)=\s+(require|require_glob)\s+(.+?)\s*$`

  def dependents
    collection = Fuse::Document::AssetCollection.new
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
            collection << p
          end
        end
      end
    end
    collection
  end
end
