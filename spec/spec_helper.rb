require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'rr'
require 'vidibus-wowza_log_parser'

Dir[File.expand_path('spec/support/**/*.rb')].each { |f| require f }

Mongoid.configure do |config|
  name = 'vidibus-wowza_log_parser_test'
  host = 'localhost'
  config.master = Mongo::Connection.new.db(name)
  # Display MongoDB logs for debugging:
  # config.master = Mongo::Connection.new("localhost", 27017, :logger => Logger.new($stdout, :info)).db(name)
  config.logger = nil
end

RSpec.configure do |config|
  config.mock_with :rr
  config.before(:each) do
    Mongoid.master.collections.select {|c| c.name !~ /system/}.each(&:drop)
  end
end
