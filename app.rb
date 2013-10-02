require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'
require 'omniauth-facebook'
require 'json'
require_relative 'models/user'

set :database, 'sqlite3:///moodlist.db'

enable :sessions

get '/' do

  if session[:user_id].nil?
    erb :login
  else
    @first_name = session[:first_name]
    erb :home
  end
end

get '/auth/:provider/callback' do
 uid = request.env['omniauth.auth'][:uid]
  first_name = request.env['omniauth.auth']['info'][:first_name]
 last_name = request.env['omniauth.auth']['info'][:last_name]

 user = User.find_or_create_by(facebook_uid: uid)
 user.update_attributes(first_name: first_name, last_name: last_name)

 session[:user_id] = request.env['omniauth.auth'][:uid]
 session[:first_name] =  first_name
 redirect '/'
end

get '/search' do
end

SCOPE = 'email'

Dotenv.load

use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], :scope => SCOPE
end