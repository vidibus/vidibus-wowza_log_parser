require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'rr'
require 'vidibus-wowza_log_parser'

Dir[File.expand_path('spec/support/**/*.rb')].each { |f| require f }
