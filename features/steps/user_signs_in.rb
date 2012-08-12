class UserSignsIn < Spinach::FeatureSteps
  include AuthSteps


  When 'I visit the home page' do
    visit root_path
  end

  Then 'I should see the login screen' do
    page.should have_css("#coreon-login")
    page.should have_no_css("#coreon-footer")
  end

  When 'I fill in "Login" with "Nobody"' do
    fill_in "Login", with: "Nobody"
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
