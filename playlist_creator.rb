require 'echonest'
require 'spotify'

module PlaylistCreator
  def self.get_playlist(params)
    current_mood = URI::escape(params[:current_mood])
    desired_mood = URI::escape(params[:desired_mood])
    style = URI::escape(params[:style])
    @mood_x, @mood_y = [0, 10]
    playlist = populate_playlist(current_mood,desired_mood,style)
    spotify_playlist = []
    playlist.each do |song|
      spotify_playlist << Spotify.return_id(song['artist_name'],song['title'])
    end
    spotify_playlist
  end

  def self.populate_playlist(current_mood,desired_mood,style)
    request_count = 0
    playlist = []
    begin
      request_count += 1

      break if request_count > 20
      song_array = Echonest.query_songs(current_mood,desired_mood, style, @mood_x, @mood_y)
      playlist = make_unique_playlist(song_array,playlist)
    end while playlist.length <= 10
    playlist
  end

  def self.make_unique_playlist(song_array, playlist)
    song_array.each do |song|
      unless in_playlist_array?(playlist, song)
        change_mood
        playlist << song
        break
      end
    end
    playlist
  end

  def self.in_playlist_array?(playlist, song)
    playlist.each do |playlist_song|
      return true if (playlist_song["title"].upcase == song["title"].upcase)
    end
    return false
  end


  def self.change_mood
    @mood_x += 1
    @mood_y = 10 - @mood_x unless @mood_y < 0
  end
end