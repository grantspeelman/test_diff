$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'test_diff'

require 'minitest/reporters'
MiniTest::Reporters.use!
require 'minitest/autorun'
