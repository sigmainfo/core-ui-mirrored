class UserSignsOut < Spinach::FeatureSteps
  include AuthSteps

  step 'I click to open the footer' do
    find("#coreon-footer .toggle").click
  end

  step 'I click on "Log out"' do
    click_on "Log out"
  end

  step 'I should see the login form' do
    page.should have_css("#coreon-login")
  end

  step 'I should see a notice "Successfully logged out"' do
    find("#coreon-notifications .info").should have_content "Successfully logged out"
  end

  step 'I should not see the footer' do
    page.should have_no_css("#coreon-footer")
  end
end
