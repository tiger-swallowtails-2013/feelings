
require 'sinatra'
require 'sinatra/activerecord'
require 'omniauth-facebook'
require 'sqlite3'
require_relative 'models/user'


SCOPE = 'email,read_stream'
enable :sessions

set :database, "sqlite3:///tables.db"
get '/' do
  redirect '/auth/facebook'

end

get '/auth/:provider/callback' do
  # we can do something special here is +state+ param is canvas
  # (see notes above in /canvas/ method for more details)
  content_type 'application/json'
  MultiJson.encode(request.env['omniauth.auth'])
end

use OmniAuth::Builder do
  provider :facebook, '240808996072944', 'c71de27a51fd8151c93d172d72bce0a9', :scope => SCOPE
end




