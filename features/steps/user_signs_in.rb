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

  And 'fill in "Password" with "se7en!"' do
    fill_in "Password", with: "se7en!"
  end

  And 'click on "Log in"' do
    click_on "Log in"
  end

  Then 'I should be within the application' do
    page.should have_no_css("#coreon-login")
    page.should have_css("#coreon-footer")
  end

  And 'I should see a notice "Successfully logged in as William Blake"' do
    find("#coreon-status .notification").should have_content "Successfully logged in as William Blake"
  end

  And 'fill in "Password" with "ei8ht?"' do
    fill_in "Password", with: "ei8ht?"
  end

  And 'should see an error "Invalid login or password"' do
    find("#coreon-status .error").should have_content "Invalid login or password"
  end

  Given 'the authentication service is not available' do
    pending 'step not implemented'
  end

  But 'I should see an alert with "Service not available"' do
    pending 'step not implemented'
  end
end
