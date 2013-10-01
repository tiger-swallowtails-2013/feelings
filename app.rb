
require 'sinatra'
require 'sinatra/activerecord'
require 'omniauth-facebook'
require 'net/http'
require 'json'
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
  session[:name] =  env['omniauth.auth'][:info][:name]

  redirect '/home'
end

get '/home' do
  @name = session[:name]
  erb :home
  end



post '/canvas/' do

    redirect "/auth/facebook?signed_request=#{request.params['signed_request']}&state=canvas"
  end

  get '/auth/failure' do
    content_type 'application/json'
    MultiJson.encode(request.env['omniauth.auth'])
  end
  
get '/search' do
  mood = URI::escape(params[:mood])
  style = URI::escape(params[:style])
  song_url = "http://developer.echonest.com/api/v4/song/search?" +
             "api_key=AUAC13N6YQZ5F1XMD&format=json&results=100&mood=#{mood}&song_type=studio&rank_type=relevance&song_min_hotttnesss=0.25&artist_min_hotttnesss=0.25&style=#{style}"
  song_uri = URI("http://developer.echonest.com/api/v4/song/search?api_key=AUAC13N6YQZ5F1XMD&format=json&results=100&mood=#{mood}&song_type=studio&rank_type=relevance&song_min_hotttnesss=0.25&artist_min_hotttnesss=0.25&style=#{style}")
  hash = JSON.parse(Net::HTTP.get(song_uri))
  @sorted_array = hash["response"]["songs"].uniq{|song| song["artist_name"]}
  
  @spotify_song_ids = get_playlist(@sorted_array)
  erb :results
end

  use OmniAuth::Builder do
    provider :facebook, '240808996072944', 'c71de27a51fd8151c93d172d72bce0a9', :scope => SCOPE
  end

helpers do
  def getUserName
    session[:name]
  end
  def get_playlist(array_of_songs)
    array_of_songs.map do |song|
      query_spotify(song["artist_name"], song["title"])
    end.select{ |value| !value.nil? }
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

