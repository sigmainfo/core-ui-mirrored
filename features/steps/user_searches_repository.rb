class UserSearchesRepository < Spinach::FeatureSteps
  include AuthSteps

  When 'I enter "poet" in the search field' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "poet"
    end
  end

  And 'I click the search button' do
    within "#coreon-search" do
      find('input[type="submit"]').click
    end
  end

  Then 'I should see "/concepts/search?search%5Bquery%5D=poet" in the navigation bar' do
    current_path.should == "/concepts/search?search%5Bquery%5D=poetfoo"
  end

  Then 'I should see a progress indicator' do
    find("#coreon-progress-indicator")["class"].should == "busy"
  end

  Given 'the repository is not available' do
    pending 'step not implemented'
  end

  Then 'I should see an error "Service is currently unavailable"' do
    pending 'step not implemented'
  end
end
