class UserSignsOut < Spinach::FeatureSteps
  include AuthSteps

  When 'I click to open the footer' do
    find("#coreon-footer .toggle").click
  end

  And 'click on "Log out"' do
    click_on "Log out"
  end

  Then 'I should see the login form' do
    page.should have_css("#coreon-login")
  end

  And 'should see a notice "Successfully logged out"' do
    find("#coreon-status .notification").should have_content "Successfully logged out"
  end

  But 'should not see the footer' do
    page.should have_no_css("#coreon-footer")
  end
end
