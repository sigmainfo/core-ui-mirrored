class UserSignsIn < Spinach::FeatureSteps
  include AuthSteps

  When 'I visit the home page' do
    visit "/"
  end

  Then 'I should see the login screen' do
    page.should have_css("#coreon-login")
    page.should have_no_css("#coreon-footer")
  end

  When 'I fill in "Email" with "nobody@blake.com"' do
    fill_in "Email", with: "nobody@blake.com"
  end

  And 'fill in "Password" with "se7en!"' do
    fill_in "Password", with: "se7en!"
  end

  And 'click on "Log in"' do
    click_on "Log in"
  end

  step 'I should not see the login screen' do
    page.should have_no_css("#coreon-login")
  end

  Then 'I should see the widgets' do
    page.should have_css("#coreon-widgets")
  end

  Then 'I should see the footer' do
    page.should have_css("#coreon-footer")
  end

  And 'I should see a notice "Successfully logged in as William Blake"' do
    find("#coreon-notifications .info").should have_content "Successfully logged in as William Blake"
  end

  And 'fill in "Password" with "ei8ht?"' do
    fill_in "Password", with: "ei8ht?"
  end

  And 'should see an error "Invalid email or password"' do
    find("#coreon-notifications .error").should have_content "Invalid email or password"
  end

  Given 'the authentication service is not available' do
    page.execute_script "Coreon.Models.Session.authRoot = 'https://this.goes.nowhere'"
  end

  But 'I should see an error "Service is currently unavailable"' do
    find("#coreon-notifications .error").should have_content "Service is currently unavailable"
  end
end
