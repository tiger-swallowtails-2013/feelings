module PlaylistCreator
	def self.get_playlist(params)
    request_count = 0
    current_mood = URI::escape(params[:current_mood])
    desired_mood = URI::escape(params[:desired_mood])
    style = URI::escape(params[:style])
    @x, @y = [0, 10]
    @playlist = []


    begin
      request_count += 1
      break if request_count > 20
      songs = get_echonest_songs(current_mood,desired_mood, style, @x, @y)
      songs.each do |song|
        unless in_playlist_array?(song)
          change_mood
          @playlist << song
          break
        end
      end
    end while @playlist.length <= 10

    spotify_playlist = []
    @playlist.each do |song|
      spotify_playlist << query_spotify(song['artist_name'],song['title'])
    end
    spotify_playlist
  end

  def self.in_playlist_array?(song)
    @playlist.each do |playlist_song|
      return true if (playlist_song["title"].upcase == song["title"].upcase)
    end
    return false
  end


  def self.get_echonest_songs(current_mood, desired_mood, style, x, y)
    # mode = '0' REMEMBER to query for mode later on
    uri_string = "http://developer.echonest.com/api/v4/playlist/static?api_key=#{ENV['ECHONEST_KEY']}" +
    "&mood=#{current_mood}^#{x}"+
    "&mood=#{desired_mood}^#{y}"+
    "&style=#{style}^100"+
    "&results=20" +
    "&type=artist-description" +
    "&song_type=studio"+
    "&song_min_hotttnesss=0.5"+
    "&artist_min_hotttnesss=0.25"+
    "&sort=song_hotttnesss-desc"
    uri = URI(URI.encode(uri_string))
    response = Net::HTTP.get(uri)
    hash = JSON.parse(response)
    result = hash["response"]["songs"]
  end

  def self.change_mood
    @x += 1
    @y = 10 - @x unless @y < 0
  end

  def self.query_spotify(artist_name, song_title)
    artist = URI::escape(artist_name).gsub(/&/, "and")
    uri = "http://ws.spotify.com/search/1/track.json?q="
    request = URI("#{uri}#{artist}")
    response = JSON.parse(Net::HTTP.get(request))
    get_spotify_song_id(response, song_title)
  end

  def self.get_spotify_song_id(all_tracks, song_title)
    result = all_tracks["tracks"].select { |track| track["name"].include? song_title}
    result.empty? ? nil : result[0]["href"].gsub(/spotify:track:/, "")
  end
end