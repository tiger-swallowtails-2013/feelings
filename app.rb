
require 'sinatra'
require 'sinatra/activerecord'
require 'omniauth-facebook'
require 'sqlite3'
require_relative 'models/user'


SCOPE = 'email'
enable :sessions

set :database, "sqlite3:///tables.db"
get '/' do
  redirect '/auth/facebook'

end

get '/auth/:provider/callback' do
  user = User.find_or_create_by(facebook_uid: env['omniauth.auth'][:uid])
  user.update_attributes(name: env['omniauth.auth'][:info][:name])
  "Welcome #{env['omniauth.auth'][:info][:name]}"
end



post '/canvas/' do

    redirect "/auth/facebook?signed_request=#{request.params['signed_request']}&state=canvas"
  end

  get '/auth/failure' do
    content_type 'application/json'
    MultiJson.encode(request.env['omniauth.auth'])
  end
  
  use OmniAuth::Builder do
    provider :facebook, '240808996072944', 'c71de27a51fd8151c93d172d72bce0a9', :scope => SCOPE
  end



