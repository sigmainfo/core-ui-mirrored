module AuthSteps
  include Spinach::DSL

  attr_accessor :me

  Given 'my name is "William Blake" with email "nobody@blake.com" and password "se7en!"' do    
    @me_password = "se7en!"
    @me = CoreClient::Auth::User.create!(
      name: "William Blake",
      emails: ["nobody@blake.com"],
      password: @me_password,
      password_confirmation: @me_password
    )  
    account = CoreClient::Auth::Account.create! name: "Nobody's Account", active: true
    repo = CoreClient::Auth::Repository.create! name: "Nobody's Repository", account_id: account.id, graph_uri: "http://localhost:3336/", active: true
    repo_user = CoreClient::Auth::RepositoryUser.create! repository: repo, user: @me, email: "nobody@blake.com", roles: [:user, :maintainer]
  end

  Given 'I am logged in' do
    visit "/"
    within "#coreon-login" do
      fill_in "Email", with: @me.emails.first
      fill_in "Password", with: @me_password
      click_button "Login"
    end
  end

  Given 'I am logged out' do
    visit "/logout"
  end
end
