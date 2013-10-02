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
    let(:uid){ "12345" }

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

    let(:uid) { "12345" }

    let(:params) {{ current_mood: "funky", desired_mood: "sad", style: "german rock"}}

  before(:each) do
    OmniAuth.config.add_mock(:facebook, {:uid => uid, :info => info })
    visit '/'
    click_on 'Log in'
  end
      
  it "lets a user choose which mood they're in, which mood they want to be in and the style" do
    expect(page).to have_select('current_mood', :with_options => ['happy', 'sad'] )
    expect(page).to have_select('desired_mood', :with_options => ['happy', 'sad'] )
    expect(page).to have_select('style', :with_options => ['Electro Trance', 'Emo'] )
  end

  it "should have the params hash set to the user selections" do
    get '/search', params
    expect(last_response).to be_ok
  end

end