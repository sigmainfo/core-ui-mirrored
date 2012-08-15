class UserSearchesRepository < Spinach::FeatureSteps
  include AuthSteps

  When 'I enter "poet" in the search field' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "poet"
    end
  end

  And 'I click the search button' do
    pending 'step not implemented'
  end

  Then 'I should see a progress indicator' do
    pending 'step not implemented'
  end

  Given 'the repository is not available' do
    pending 'step not implemented'
  end

  Then 'I should see an error "Service is currently unavailable"' do
    pending 'step not implemented'
  end
end
