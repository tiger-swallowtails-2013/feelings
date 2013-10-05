$LOAD_PATH.unshift(File.expand_path('.'))
require 'models/song'
require 'typhoeus'

module Spotify


	def self.query_id(all_tracks, song_title)
		# tracks_in_us = all_tracks["tracks"].select {|track| track["album"]["availability"]["territories"].include?("US")}
		result = all_tracks["tracks"].select { |track| track["name"].include? song_title}
		results_in_us = playable_in_us?(result)
		results_in_us.empty? ? nil : results_in_us[0]["href"].gsub(/spotify:track:/, "")
	end


	def self.get_songs(playlist)
		track_title_array = []
		hydra = Typhoeus::Hydra.new

		requests = playlist.map do |song|
			track_title_array << song["title"]

			artist = song["artist_name"]
			artist = URI::escape(artist).gsub(/&/, "and")
			uri = "http://ws.spotify.com/search/1/track.json?q="
			request = URI("#{uri}#{artist}")
			Typhoeus::Request.new(request) 
		end
		requests.each { |request| hydra.queue(request)}
		hydra.run
		artist_array = requests.map { |request| JSON.parse(request.response.response_body) }
		spotify_playlist = []
		artist_array.each_with_index do |artist_tracks, index|
			spotify_playlist << query_id(artist_tracks,track_title_array[index]) 
		end
		spotify_playlist
	end

	def self.playable_in_us?(result)
		result.select { |track| track["album"]["availability"]["territories"].include?("US") }
	end

end
