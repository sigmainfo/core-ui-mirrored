class UserSignsIn < Spinach::FeatureSteps
  Given 'my name is "William Blake" with login "Nobody" and password "se7en!"' do
    CoreClient::Auth.create_user "William Blake", "Nobody", "se7en!"
  end

  And 'I am logged out' do
    click_on "Log out"
  end

  When 'I visit the home page' do
    visit root_path
  end

  Then 'I should see the login form' do
    pending 'step not implemented'
  end

  When 'I fill in "Login" with "Nobody"' do
    pending 'step not implemented'
  end

  And 'fill in "Password" with "se7en"' do
    pending 'step not implemented'
  end

  And 'click on "Log in"' do
    pending 'step not implemented'
  end

  Then 'I should see the application desktop' do
    pending 'step not implemented'
  end

  And 'I should see a notice "Logged in successfully as Wiliam Blake"' do
    pending 'step not implemented'
  end

  And 'fill in "Login" with "Nobody"' do
    pending 'step not implemented'
  end

  And 'fill in "Password" with "ei8ht"' do
    pending 'step not implemented'
  end

  Then 'I should not see the application desktop' do
    pending 'step not implemented'
  end

  And 'should see an alert with "Invalid login or password"' do
    pending 'step not implemented'
  end

  Given 'the authentication service is not available' do
    pending 'step not implemented'
  end

  But 'I should see an alert with "Service not available"' do
    pending 'step not implemented'
  end
end
