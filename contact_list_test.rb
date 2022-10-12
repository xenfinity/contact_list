ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "contact_list"

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup

  end
end