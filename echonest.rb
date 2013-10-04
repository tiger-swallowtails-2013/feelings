module Echonest
	def self.query_songs(current_mood, desired_mood, style, x, y)
    uri_string = "http://developer.echonest.com/api/v4/playlist/static?api_key=#{ENV['ECHONEST_KEY']}" +
    "&mood=#{current_mood}^#{x}"+
    "&mood=#{desired_mood}^#{y}"+
    "&style=#{style}^5"+
    "&results=50" +
    "&type=artist-description" +
    "&song_type=studio"+
    "&song_min_hotttnesss=0.2"+
    "&artist_min_hotttnesss=0.2"+
    "&sort=song_hotttnesss-desc"
    uri_address = URI(URI.encode(uri_string))
    response = Net::HTTP.get(uri_address)
    response_hash = JSON.parse(response)
    response_hash["response"]["songs"]
  end
end
