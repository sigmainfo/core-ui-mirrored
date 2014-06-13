module Authentication
  def create_account(name, active: true, state: :confirmed)
    CoreClient::Auth::Account.create!(
      name: name,
      active: active,
      state: state
    )
  end

  def create_repository(name, account: default_account)
    CoreClient::Auth::Repository.create!(
      name: name,
      account_id: account.id,
      graph_uri: 'http://localhost:3336/',
      active: true
    )
  end

  def create_user(name, email, password: 'UV3J#OxSN5]l8')
    CoreClient::Auth::User.create!(
      name: name,
      emails: [email],
      password: password,
      password_confirmation: password
    )
  end

  def create_repository_user(*roles, repository: current_repository,
                                     user: current_user)
    roles = roles.map &:to_s
    roles.push(:user) if roles.empty?

    CoreClient::Auth::RepositoryUser.create!(
      repository: repository,
      user: user,
      email: user.emails.first,
      roles: roles,
      state: :confirmed
    )
  end
  alias grant_repository_access create_repository_user

  def default_account
    @default_account ||= create_account 'Test Account'
  end

  def current_repository
    @current_repository ||= create_repository 'Test Repository'
  end

  def current_user
    @current_user ||= create_user 'Test User', 'test@coreon.com'
  end

  def guest_user
    @guest_user ||= create_user(
      'guest',
      'guest@coreon.com',
      password: 'TaiD@?mkPVWmh7hj&HgguBom647i&A'
    )
  end

  def login(email: current_user.emails.first, password: 'UV3J#OxSN5]l8')
    visit '/'
    within '#coreon-login' do
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Log in'
    end
    page.should have_css('#coreon-footer')
    CoreAPI.session =
      page.evaluate_script('localStorage.getItem("coreon-session")')
  end

  def logout
    visit '/logout'
  end
end
