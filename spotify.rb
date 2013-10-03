$LOAD_PATH.unshift(File.expand_path('.'))
require 'models/song'

module Spotify
	def self.return_id(artist_name, song_title)
		song = Song.find_or_create_by(artist_name: artist_name, title: song_title)
		unless song.spotify_id.nil?
			return song.spotify_id
		else
			artist = URI::escape(artist_name).gsub(/&/, "and")
			uri = "http://ws.spotify.com/search/1/track.json?q="
			request = URI("#{uri}#{artist}")
			response = JSON.parse(Net::HTTP.get(request))
			song.update_attributes(spotify_id: query_id(response,song_title))
			return song.spotify_id
		end
	end

	def self.query_id(all_tracks, song_title)
		result = all_tracks["tracks"].select { |track| track["name"].include? song_title}
		result.empty? ? nil : result[0]["href"].gsub(/spotify:track:/, "")
	end
end
