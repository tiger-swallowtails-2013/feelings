require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'net/http'
require_relative 'models/user'
require_relative 'config/dotenv_helper'
require_relative 'config/omniauth_helper'
require 'pry'
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
  @songs = get_playlist(params)
  erb :home
end

helpers do

  def get_songs(current_mood, desired_mood, style, x, y)
    # mode = '0' REMEMBER to query for mode later on 
    uri_string = "http://developer.echonest.com/api/v4/song/search?api_key=AUAC13N6YQZ5F1XMD&format=json&results=20" + 
    "&mood=#{current_mood}^#{x}"+
    "&mood=#{desired_mood}^#{y}"+
    "&song_type=studio"+
    "&rank_type=relevance"+
    "&song_min_hotttnesss=0.25"+
    "&artist_min_hotttnesss=0.25"+
    "&style=#{style}^10"+
    "&sort=artist_hotttnesss-desc"
    uri = URI(URI.encode(uri_string))
    response = Net::HTTP.get(uri)
    hash = JSON.parse(response)
    result = hash["response"]["songs"]
    # p result
  end  

  def get_playlist(params)
    playlist_array = [{:test => 'test'}]
    current_mood = URI::escape(params[:current_mood])
    desired_mood = URI::escape(params[:desired_mood])
    style = URI::escape(params[:style])
    x = 0.1
    y = 1.9
    until playlist_array.length == 4
      # p change_mood(x,y)
      x = change_mood(x,y)[0]
      y = change_mood(x,y)[1]
      songs = get_songs(current_mood, desired_mood, style, x, y)
      # puts "*"* 30
      # puts songs.inspect
      songs.each do |song|

          if !playlist_array[-1].has_value?(song['artist_id'])
            puts '================'
            puts song['artist_name']
            puts '++++++++++++++++'
            puts 'playlist array: '
            puts playlist_array
            playlist_array << song
          end
      end
      puts "*"*30
      p songs
    end  
    playlist_array
  end

  def change_mood(x,y)
    array = []
    increment = 0
    x += increment 
    y -= increment unless y < 1
    array << x.round(2)
    array << y.round(2)
    return array
  end
end



