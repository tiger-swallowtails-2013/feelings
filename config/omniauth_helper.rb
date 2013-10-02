require 'omniauth-facebook'

SCOPE = 'email'

use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], :scope => SCOPE
end
