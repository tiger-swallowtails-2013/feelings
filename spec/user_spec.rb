require_relative './spec_helper'
require_relative '../app'

describe "user model" do
  it "should create a user if they don't already exist" do
    user = User.find_or_create_by(first_name: "Max", last_name: "Davila",facebook_uid: '9801293081')
    found_user = User.find(user.id)
    expect(user).to eq(found_user)
  end
end

describe "user log in: ", :type => :feature do
  
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
    visit '/'
    click_on 'Log in'
    expect(page).to have_content("Welcome Daniel")
  end

end

describe "user can create playlist: ", :type => :feature do
    let(:info){
      {
      first_name: "Daniel",
      last_name: "Trostli",
      }
    }

    let(:uid){
      "12345"
      }
      
  it "lets a user choose which mood they're in and which mood they want to be in" do
    OmniAuth.config.add_mock(:facebook, {:uid => uid, :info => info })
    visit '/'
    click_on 'Log in'
    expect(page).to have_select('current_mood', :with_options => ['happy', 'sad'] )
  end
end