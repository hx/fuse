require 'optparse'
require 'thin'

module Fuse

  VERSION = '0.1.3'

  def self.root
    @root ||= File.expand_path File.dirname(__FILE__)
  end

end

$:.unshift Fuse.root unless $:.include?(Fuse.root)

require 'fuse/main'
require 'fuse/exceptions'
require 'fuse/server'
require 'fuse/document'
require 'fuse/document/asset'
require 'fuse/document/asset_types'
require 'fuse/document/asset_collection'

Fuse.main if $0 == __FILE__
