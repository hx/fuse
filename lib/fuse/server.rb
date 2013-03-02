require 'nokogiri'

class Fuse::Server

  def initialize(options)
    @options = options
  end

  def call(env)

    request = Rack::Request.new(env)

    call_options = @options.merge Hash[request.GET.map{ |k, v| [k.to_sym, v] }]

    if @root && (asset = Fuse::Document::Asset.for(request.path))
      return asset.call(env)
    end

    begin
      doc = Fuse::Document.new(call_options)
      @root = doc.root
    rescue Fuse::Exception::SourceUnknown::TooManySources
      doc = render_list($!.options, $!.option_name, request)
    rescue Fuse::Exception
      if $!.message
        doc = render_error($!.message)
      else
        raise
      end
    end

    [200, {'Content-Type' => 'text/html'}, [doc.to_s]]

  end

  private

    def render_error(text)
      render_body do |h|
        h.p { h.text text }
      end
    end

    def render_list(assets, key, request)
      render_body do |h|
        h.h3 { h.text "Choose #{key}:" }
        h.ul {
          assets.each do |asset|
            h.li {
              h.a(href: '?' + Rack::Utils.build_query(request.GET.merge(key.to_s => asset))) {
                h.text asset
              }
            }
          end
        }
      end
    end

    def render_body
      Nokogiri::HTML::Builder.new do |h|
        h.html {
          h.head { h.title { h.text 'Fuse' } }
          h.body { yield h }
        }
      end.to_html
    end

end
