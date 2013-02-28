require 'optparse'
require 'thin'

module Fuse

  DEFAULTS = {
    common: {
      source: '.'
    },
    server: {
    },
    compile: {
    }
  }

  def self.main

    options = {}

    options_parser = OptionParser.new do |opts|

      opts.banner = 'Usage: fuse [command] [options]'
      opts.separator ''
      opts.separator 'Commands:'
      opts.separator '    server  : Run a local testing server'
      opts.separator '    compile : Compile the document and send to STDOUT'
      opts.separator ''
      opts.separator 'Options:'

      opts.on('-s', '--source [FILE|DIR]', 'The source directory, or HTML or XML document') do |doc|
        options[:source] = doc
      end

      opts.on('-x', '--xsl FILE', 'XSL transformation stylesheet') do |xsl|
        abort "#{xsl} isn't a valid XSL stylesheet" unless xsl.match(/\.xsl$/i)
        options[:xsl] = xsl
      end

      opts.on('-p', '--port PORT', Integer, 'Port on which to listen (only with "server" command)') do |port|
        options[:port] = port
      end

      opts.on('-t', '--title TITLE', 'HTML document title') { |t| options[:title] = t }

      opts.on_tail('-h', '--help', 'Show this message') { puts opts.to_s }

    end

    options_parser.parse!

    options = merge_defaults(options)

    case ARGV[0]

      when 'server'
        Thin::Server.start('0.0.0.0', options[:port] || 9460) do
          use Rack::ShowExceptions
          run Server.new(options)
        end

      when 'compile'
        begin
          print Document.new(options).to_s
        rescue Exception::SourceUnknown::TooManySources
          $stderr.puts "Found more than one potential #{$!.option_name} document. Please specify one with --#{$!.option_name}."
          $stderr.puts $!.options.join "\n"
        rescue Exception
          $!.message ? $stderr.puts($!.message) : raise
        end

      else
        puts options_parser

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

end
