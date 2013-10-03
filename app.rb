require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'net/http'
require_relative 'models/user'
require_relative 'config/dotenv_helper'
require_relative 'config/omniauth_helper'

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
 session[:fb_token] = request.env['omniauth.auth']['credentials']['token']
 redirect '/'
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/search' do
  @songs = get_playlist(params)
  erb :home
end


helpers do
  def get_playlist(params)
    current_mood = URI::escape(params[:current_mood])
    style = URI::escape(params[:style])
    mode = '0'
    uri = URI("http://developer.echonest.com/api/v4/song/search?api_key=#{ENV['ECHONEST_KEY']}&format=json&results=5&mood=#{current_mood}&song_type=studio&mode=#{mode}&rank_type=relevance&song_min_hotttnesss=0.25&artist_min_hotttnesss=0.25&style=#{style}&sort=artist_hotttnesss-desc")
    puts uri
    response = Net::HTTP.get(uri)
    hash = JSON.parse(response)
    result = hash["response"]["songs"]
    p ENV['ECHONEST_KEY']
    result.first
  end
end



