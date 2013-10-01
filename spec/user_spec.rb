require_relative './spec_helper'
require_relative '../app'

describe "user model" do
  it "should create a user if they don't already exist" do
    user = User.find_or_create_by(first_name: "Max", last_name: "Davila",facebook_uid: '9801293081')
    found_user = User.find(user.id)
    expect(user).to eq(found_user)
  end
end

describe "user can view mood list" do
  
  it "should show the home page with the fb button" do
    visit '/'
    expect(page).to have_content("Log in")
  end

end