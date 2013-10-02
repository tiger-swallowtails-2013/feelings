require_relative './spec_helper'
require_relative '../app'

describe "user model" do
  it "should create a user if they don't already exist" do
    user = User.find_or_create_by(first_name: "Max", last_name: "Davila",facebook_uid: '9801293081')
    found_user = User.find(user.id)
    expect(user).to eq(found_user)
  end
end

describe "user can view mood list", :type => :feature do
  
    let(:info){
      {
      first_name: "Daniel",
      last_name: "Trostli",
      }
    }

    let(:uid){
      "12345"
      }
      
  it "should show the home page with the fb button" do
    visit '/'
    expect(page).to have_content("Log in")
  end

  it "shows welcome page after successful log in" do
    OmniAuth.config.add_mock(:facebook, {:uid => uid, :info => info })

    user = User.find_or_create_by(first_name: "Daniel", facebook_uid: '12123')
    visit '/'
    click_on 'Log in'
    expect(page).to have_content("Welcome #{user.first_name}")
  end

end