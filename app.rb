$LOAD_PATH.unshift(File.expand_path('.'))
require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'net/http'
require 'models/user'
require 'config/dotenv_helper'
require 'config/omniauth_helper'

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
 session[:first_name] =  first_name
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
  def is_not_logged_in?
    session[:facebook_uid].nil?
  end

  def get_first_name
    user = User.find_by_facebook_uid(session[:facebook_uid])
    user.first_name
  end

  def get_playlist(params)
    current_mood = URI::escape(params[:current_mood])
    style = URI::escape(params[:style])
    mode = '0'
    uri = URI("http://developer.echonest.com/api/v4/song/search?api_key=#{ENV['ECHONEST_KEY']}&format=json&results=5&mood=#{current_mood}&song_type=studio&mode=#{mode}&rank_type=relevance&song_min_hotttnesss=0.25&artist_min_hotttnesss=0.25&style=#{style}&sort=artist_hotttnesss-desc")
    response = Net::HTTP.get(uri)
    hash = JSON.parse(response)
    result = hash["response"]["songs"]
    result.first
  end

  def query_spotify(artist_name, song_title)
    artist = URI::escape(artist_name).gsub(/&/, "and")
    uri = "http://ws.spotify.com/search/1/track.json?q="
    request = URI("#{uri}#{artist}")
    response = JSON.parse(Net::HTTP.get(request))
    get_spotify_song_id(response, song_title)
  end

  def get_spotify_song_id(all_tracks, song_title)
    result = all_tracks["tracks"].select { |track| track["name"].include? song_title}
    result.empty? ? nil : result[0]["href"].gsub(/spotify:track:/, "")
  end

end



