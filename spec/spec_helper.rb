require 'rspec'
require 'capybara/rspec'

require File.expand_path('../../lib/fuse', __FILE__)

Capybara.app = Fuse::Server.new  Fuse::DEFAULTS[:common].merge Fuse::DEFAULTS[:server].merge source: 'spec/fixtures/html'
