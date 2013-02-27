class Fuse::Server

  def initialize(options)
    @options = options
  end

  def call(env)

    path = env['REQUEST_PATH']

    if (asset = Fuse::Document::Asset.for(path))
      asset.call(env)
    else
      doc = Fuse::Document.new(@options)
      [200, {'Content-Type' => 'text/html'}, [doc.to_s]]
    end

  end
end
