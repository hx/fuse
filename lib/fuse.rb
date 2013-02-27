require 'optparse'
require 'thin'
require 'pp'

module Fuse

  VERSION = '0.1.0'

  def self.root
    @root ||= File.expand_path File.dirname(__FILE__)
  end

  Dir[File.join root, '**/*.rb'].each { |file| require file }

  def self.main

    options = {
        source: '.'
    }

    options_parser = OptionParser.new do |opts|

      opts.banner = 'Usage: phd [command] [options]'
      opts.separator ''
      opts.separator 'Commands:'
      opts.separator '    server  : Run a local testing server'
      opts.separator '    compile : Compile the document and send to STDOUT'
      opts.separator ''
      opts.separator 'Options:'

      opts.on('-s', '--source [FILE|DIR]', 'The source directory, or HTML or XML document') do |doc|
        options[:source] = doc
      end

      opts.on('-t', '--xsl FILE', 'XSL transformation stylesheet') do |xsl|
        abort "#{xsl} isn't a valid XSL stylesheet" unless xsl.match(/\.xsl$/i)
        options[:xsl] = xsl
      end

      opts.on('-p', '--port PORT', Integer, 'Port on which to listen (only with "server" command)') do |port|
        options[:port] = port
      end

      opts.on_tail('-h', '--help', 'Show this message') { puts opts.to_s }

    end

    options_parser.parse!

    case ARGV[0]

      when 'server'
        Thin::Server.start('0.0.0.0', options[:port] || 9460) do
          use Rack::ShowExceptions
          run Server.new(options)
        end

      when 'compile'
        #print Document.new(options)
        #pp Document::Asset.glob(Dir.pwd).of_type(Document::Asset::StyleSheet).sort
        doc = Document.new(options)
        puts "source: #{doc.source_path}"
        puts "xsl:    #{doc.xsl_path}"
      else
        puts options_parser

    end

  end

end

Fuse.main if $0 == __FILE__
