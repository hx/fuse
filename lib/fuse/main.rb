require 'optparse'
require 'thin'

module Fuse

  DEFAULTS = {
    common: {
      source: '.',
      encoding: 'UTF-8',
      preserve_white: true
    },
    server: {
        addr: '127.0.0.1',
        port: 9460,
        embed_assets: false
    },
    compile: {
        embed_assets: true,
        compress_assets: true
    }
  }

  SUMMARY_WIDTH  = 30
  SUMMARY_INDENT = 4

  def self.main

    options = {}

    options_parser = OptionParser.new do |opts|

      "

Usage: #{$0} command [options]

Commands:
    server  : Run a local testing server
    compile : Compile the document and send to STDOUT

Options:

      ".strip.lines.each { |line| opts.separator line }

      opts.on('-a',
              '--addr',
              wrap("Server binding address. Defaults to #{DEFAULTS[:server][:addr]}. Use 0.0.0.0 for access from other computers. Be careful; server will allow access to any locally accessible file of Fuse's supported types.")
      ) do |addr|
        options[:addr] = addr
      end

      opts.on('-c',
              '--[no-]compress-assets',
              'Compress assets.'
      ) do |compress|
        options[:compress_assets] = compress
      end

      opts.on('-e',
              '--encoding CHARSET',
              wrap("Output encoding. Default is #{DEFAULTS[:common][:encoding]}.")
      ) do |e|
        options[:encoding] = e
      end

      opts.on('-m',
              '--[no-]embed-assets',
              'Embed assets.'
      ) do |embed|
        options[:embed_assets] = embed
      end

      opts.on('-p',
              '--port PORT',
              Integer,
              wrap("Port on which to listen (only with 'server' command). Default is #{DEFAULTS[:server][:port]}.")
      ) do |port|
        options[:port] = port
      end

      opts.on('-s',
              '--source [FILE|DIR]',
              wrap('The source directory, or HTML or XML document. Default is current directory.')
      ) do |doc|
        options[:source] = doc
      end

      opts.on('-t',
              '--title TITLE',
              'HTML document title.'
      ) do |t|
        options[:title] = t
      end

      opts.on('-v',
              '--version',
              'Show Fuse version.'
      ) { abort Fuse::VERSION }

      opts.on('-w',
              '--[no-]preserve-white',
              wrap("Preserve all white space in HTML. Default is #{DEFAULTS[:common][:preserve_white]}.")
      ) { |w| options[:preserve_white] = w }

      opts.on('-x',
              '--xsl FILE',
              wrap('XSL transformation stylesheet. Default is current directory.')
      ) do |xsl|
        abort "#{xsl} isn't a valid XSL stylesheet" unless xsl.match(/\.xsl$/i)
        options[:xsl] = xsl
      end

      opts.on_tail('-h', '--help', 'Show this message.') { summary opts }

    end

    options_parser.parse!

    options = merge_defaults(options)

    case ARGV[0]

      when 'server'
        Thin::Server.start(options[:addr], options[:port]) do
          use Rack::ShowExceptions
          run Server.new(options)
        end

      when 'compile'
        begin
          doc = Document.new(options)
          log "Compiling #{doc.source_path}"
          out = doc.to_s
          print out
          log "Wrote #{out.bytesize} byte(s) to STDOUT.", :success
        rescue Exception::SourceUnknown::TooManySources
          log "Found more than one potential #{$!.option_name} document. Please specify one with --#{$!.option_name}.", :notice
          log $!.options.join "\n"
        rescue Exception
          $!.message ? log($!.message, :error) : raise
        end

      else
        summary options_parser

    end

  end

  private

    def self.merge_defaults(options)
      if (defaults = DEFAULTS[(ARGV[0] || '').to_sym])
        defaults.merge(DEFAULTS[:common]).merge(options)
      else
        options
      end
    end

    def self.wrap(text, width = 80 - SUMMARY_WIDTH)
      text.gsub(/(.{1,#{width}})(\s+|$)/, "\\1\n#{' ' * (SUMMARY_WIDTH + SUMMARY_INDENT + 1)}").strip
    end

    def self.summary(opts)
      abort opts.summarize([], SUMMARY_WIDTH, SUMMARY_WIDTH - 1, ' ' * SUMMARY_INDENT).join
    end

end
