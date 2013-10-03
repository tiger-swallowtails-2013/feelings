$LOAD_PATH.unshift(File.expand_path('.'))
require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'net/http'
require 'models/user'
require 'config/dotenv_helper'
require 'config/omniauth_helper'
require 'playlist_creator'

set :database, 'sqlite3:///moodlist.db'

enable :sessions

get '/' do
  if is_not_logged_in?
    erb :login
  else
    @first_name = get_first_name
    erb :home
  end
end

get '/auth/:provider/callback' do
 uid = request.env['omniauth.auth'][:uid]
 first_name = request.env['omniauth.auth']['info'][:first_name]
 last_name = request.env['omniauth.auth']['info'][:last_name]

 user = User.find_or_create_by(facebook_uid: uid)
 user.update_attributes(first_name: first_name, last_name: last_name)

 session[:facebook_uid] = request.env['omniauth.auth'][:uid]
 redirect '/'
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/search' do
  @songs = PlaylistCreator.get_playlist(params)
  @current_mood = params[:current_mood]
  @desired_mood = params[:desired_mood]
  @style = params[:style]
  erb :home
end


helpers do

  def is_not_logged_in?
    session[:facebook_uid].nil?
  end

  def get_first_name
    user = User.find_by_facebook_uid(session[:facebook_uid])
    user.first_name
  end

end



