require 'rack/test'
require 'turn/autorun'
Turn.config.format = :outline

# Override environment variables for testing.
# The URLs do not matter.
#
ENV['RACK_ENV'] = 'test'
ENV['LONG']     = 'http://test.com/'
ENV['SHORT']    = 'http://te.st'
ENV['MEDIA']    = 'test'
ENV['SLUG']     = '4'
ENV['LOGIN']    = 'user'
ENV['PASS']     = 'pass'
ENV['TOKEN']    = 'token'
ENV['PURGE']    = '7'

require_relative './test_methods.rb'
require_relative './test_utils.rb'
require_relative '../app.rb'