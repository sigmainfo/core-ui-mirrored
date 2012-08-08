class UserSignsOut < Spinach::FeatureSteps
  include AuthSteps

  When 'I click to open the footer' do
    find("#coreon-footer .toggle").click
  end

  And 'click on "Log out"' do
    click_on "Log out"
  end

  Then 'I should be on the login page' do
    current_path.should == "/account/login"
  end

  And 'should see a notice "Successfully logged out"' do
    find("#coreon-status .notification").should have_content "Successfully logged out"
  end
end
