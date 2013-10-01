require 'sinatra'
require 'sinatra/activerecord'
require_relative 'models/user'

set :database, 'sqlite3:///moodlist.db'

get '/' do
  "Log in"
end
