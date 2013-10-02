require_relative '../app'
require 'capybara/rspec'

Capybara.app = Sinatra::Application

OmniAuth.config.test_mode = true

