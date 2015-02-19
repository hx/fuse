module Fuse

  LOG_COLOURS = {
      info:     6, # cyan
      success:  2, # green
      error:    1, # red
      notice:   3  # yellow
  }

  class << self

    def root
      @root ||= File.expand_path File.dirname(__FILE__)
    end

    def log_file=(file)
      @log_file = file
    end

    def log_file
      @log_file ||= $stderr
    end

    def log(message, type = nil)
      colour = 30 + (LOG_COLOURS[type] || LOG_COLOURS[:info])
      log_file.puts "\x1b[#{colour}m#{message}\x1b[0m"
    end

  end

end

$:.unshift Fuse.root unless $:.include?(Fuse.root)

require 'fuse/version'
require 'fuse/main'
require 'fuse/exceptions'
require 'fuse/server'
require 'fuse/document'
require 'fuse/document/asset'
require 'fuse/document/asset/has_dependents'
require 'fuse/document/asset/style_sheet'
require 'fuse/document/asset/java_script'
require 'fuse/document/asset/font'
require 'fuse/document/asset_types'
require 'fuse/document/asset_collection'

Fuse.main if $0 == __FILE__
