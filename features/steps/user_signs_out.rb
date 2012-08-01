class UserSignsOut < Spinach::FeatureSteps
  include AuthSteps

  When 'I click to open the footer' do
    find("#coreon-footer .toggle").click
  end

  And 'click on "Log out"' do
    pending 'step not implemented'
  end

  Then 'I should not be within the application' do
    pending 'step not implemented'
  end

  But 'should see the login form' do
    pending 'step not implemented'
  end

  And 'should see a notice "Successfully logged out"' do
    pending 'step not implemented'
  end
end
