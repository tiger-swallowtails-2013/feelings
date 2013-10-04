$LOAD_PATH.unshift(File.expand_path('.'))
require './app'
ACTIVERECORD::BASE.establish_connection(ENV["DATABASE_URL"] || "sqlite3:///moodlist.db")
run Sinatra::Application

