require 'base64'

class Fuse::Document::Asset

  def self.[](dir)
    assets = Fuse::Document::AssetCollection.new
    Dir[File.join dir, '**/*.*'].each do |full_path|
      asset = self.for(full_path[dir.length..-1], dir)
      assets << asset if asset
    end
    assets
  end

  def self.for(path, root = Dir.pwd)
    full_path = File.join root, path
    return unless File.exists? full_path
    type = TYPES[(File.extname(path)[1..-1] || '').to_sym]
    (@cache ||= {})[File.expand_path full_path] ||= type.new(path, root) if type
  end

  attr_reader :path

  def initialize(path, root)
    @root = root
    @path = path
  end

  def full_path
    @full_path ||= File.join @root, @path
  end

  def relative_path
    @relative_path ||= path.sub(%r`^/`, '')
  end

  def raw
    @raw ||= File.open(full_path, 'rb') { |f| f.read }
  end

  def filtered
    @filtered ||= filter? ? filter : raw
  end

  def filter?
    respond_to? :filter
  end

  def call(env)
    if filter?
      body = filter
      [200, {'Content-Type' => type, 'Content-Length' => body.length.to_s}, [body]]
    else
      Rack::File.new(@root).call(env)
    end
  end

  def type
    @type ||= Rack::Mime.mime_type('.' + extension)
  end

  def to_datauri(compress = false)
    'data:%s;base64,%s' % [
        type,
        Base64.strict_encode64(compress && respond_to?(:compress) ? self.compress : raw)
    ]
  end

  def extension
    @extension ||= File.extname(path).downcase[1..-1]
  end

end
