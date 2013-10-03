$LOAD_PATH.unshift(File.expand_path('.'))
require 'app'
require 'capybara/rspec'
require 'rack/test'

Capybara.app = Sinatra::Application

OmniAuth.config.test_mode = true

Rspec.configure do |conf|
  conf.include Rack::Test::Methods
end


def app
  Sinatra::Application
end
