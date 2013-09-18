# encoding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'vidibus/wowza_log_parser'

Gem::Specification.new do |s|
  s.name        = 'vidibus-wowza_log_parser'
  s.version     = Vidibus::WowzaLogParser::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = 'punkrats'
  s.email       = 'andre@webwarelab.com'
  s.homepage    = 'https://github.com/vidibus/vidibus-wowza_log_parser'
  s.summary     = 'A simple parser for Wowza access logs'
  s.description = s.summary
  s.license     = 'MIT'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'vidibus-wowza_log_parser'

  s.add_development_dependency 'bundler', '>= 1.0.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rr'

  s.files = Dir.glob('{lib,app,config}/**/*') + %w[LICENSE README.md Rakefile]
  s.require_path = 'lib'
end
