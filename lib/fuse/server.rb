require 'nokogiri'

class Fuse::Server

  def initialize(options)
    @options = options
    Fuse.log "Starting Fuse Server v#{Fuse::VERSION}", :success
  end

  def call(env)

    request = Rack::Request.new(env)
    result = nil
    status = 200

    call_options = @options.merge Hash[request.GET.map{ |k, v| [k.to_sym, v] }]

    if @root && (asset = Fuse::Document::Asset.for(request.path))
      log env, "Serve asset #{asset.path}"
      return asset.call(env)
    end

    begin
      doc = Fuse::Document.new(call_options)
      @root = doc.root
      result = doc.to_s
      log env, "Using    #{doc.xsl_path} for transformation" if doc.xsl_path
      log env, "Rendered #{doc.source_path} (#{result.length} bytes)", :success

    rescue Fuse::Exception::SourceUnknown::TooManySources
      result = render_list($!.options, $!.option_name, request)
      log env, 'Multiple source document options', :notice

    rescue Fuse::Exception
      if $!.message
        result = render_error($!.message)
        log env, $!.message, :notice
      else
        raise
      end

    end if request.path == '/'

    if result.nil?
      log env, 'Not found', :error
      status = 404
      result = render_error('Not found')
    end

    [status, {'Content-Type' => 'text/html'}, [result]]

  end

  private

    def log(env, message, *args)
      Fuse.log_file.write "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} [#{env['REMOTE_ADDR']}] GET #{env['REQUEST_PATH']} "
      Fuse.log message, *args
    end

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
