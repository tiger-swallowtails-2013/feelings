# unless ["production", "staging"].include? ENV['RACK_ENV']
  require 'dotenv'
  Dotenv.load
# end


