require 'optparse'
require 'thin'

module Fuse

  VERSION = '0.1.6'

  LOG_COLOURS = {
      info:     6, # cyan
      success:  2, # green
      error:    1, # red
      notice:   3  # yellow
  }

  def self.root
    @root ||= File.expand_path File.dirname(__FILE__)
  end

  def self.log_file=(file)
    @log_file = file
  end

  def self.log_file
    @log_file ||= $stderr
  end

  def self.log(message, type = nil)
    m = "\x1b["
    m << (30 + (LOG_COLOURS[type] || LOG_COLOURS[:info])).to_s
    m << 'm'
    m << message
    m << "\x1b[0m"
    log_file.puts m
  end

end

$:.unshift Fuse.root unless $:.include?(Fuse.root)

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
