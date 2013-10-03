module Spotify
	def self.query(artist_name, song_title)
    artist = URI::escape(artist_name).gsub(/&/, "and")
    uri = "http://ws.spotify.com/search/1/track.json?q="
    request = URI("#{uri}#{artist}")
    response = JSON.parse(Net::HTTP.get(request))
    get_song_id(response, song_title)
  end

  def get_song_id(all_tracks, song_title)
    result = all_tracks["tracks"].select { |track| track["name"].include? song_title}
    result.empty? ? nil : result[0]["href"].gsub(/spotify:track:/, "")
  end
end
