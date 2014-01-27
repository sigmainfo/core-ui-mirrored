module AuthSteps
  include Spinach::DSL

  attr_accessor :me, :repository

  def repository_user( *roles )
    roles.map!( &:to_s )
    roles.unshift( 'user' ) unless roles.include?( 'user' )
    @me_password = "se7en!"
    @me = CoreClient::Auth::User.create!(
      name: "William Blake",
      emails: ["nobody@blake.com"],
      password: @me_password,
      password_confirmation: @me_password
    )
    @account = CoreClient::Auth::Account.create! name: "Nobody's Account", active: true, state: :confirmed
    @repository = CoreClient::Auth::Repository.create! name: "Nobody's Repository", account_id: @account.id, graph_uri: "http://localhost:3336/", active: true
    @repo_user = CoreClient::Auth::RepositoryUser.create! repository: @repository,
                                                          user: @me,
                                                          email: "nobody@blake.com",
                                                          roles: roles,
                                                          state: :confirmed
  end

  def login_window
    find '#coreon-login'
  end

  def footer
    find '#coreon-footer'
  end

  def login
    visit "/"
    within login_window do
      fill_in "Email", with: @me.emails.first
      fill_in "Password", with: @me_password
      click_button "Log in"
    end
    page.should have_css( '#coreon-footer' )
    CoreAPI.session = page.evaluate_script('localStorage.getItem("coreon-session")')
  end

  step 'my name is "William Blake" with email "nobody@blake.com" and password "se7en!"' do
    @repository_user = repository_user
  end

  step 'I am logged in as user of the repository' do
    @repository_user = repository_user
    login
  end

  step 'I am logged in as maintainer of the repository' do
    @repository_user = repository_user( :maintainer )
  end

  step 'I am no maintainer of the repository' do
    # set user_name to mark user as dirty
    @repo_user.update_attributes roles: ["user"], user_name: "123"
  end

  step 'I am a maintainer of the repository' do
    # set user_name to mark user as dirty
    @repo_user.update_attributes roles: ["user", "maintainer"], user_name: "xxx"
  end

  step 'I am logged in' do
    login
  end

  step 'I am logged out' do
    visit "/logout"
  end

  step 'I visit the repository root page' do
    visit "/#{@repository.id}"
  end

end
