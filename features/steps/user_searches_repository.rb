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

  Then 'I should be on the search results page for query "poet"' do
    current_path.should == "/#{current_repository.id}/concepts/search/poet"
  end

  And 'I should see a listing of the search results' do
    page.should have_css('.concept-list')
  end

  Then 'I should see a progress indicator' do
    find("#coreon-progress-indicator")["class"].should == "busy"
  end

  Given 'the repository is not available' do
    page.execute_script 'Coreon.application.graphUri = function() { return "https://black.hole" }'
  end

  Then 'I should see an error "Service is currently unavailable"' do
    page.should have_css("#coreon-notifications .error", text: "Service is currently unavailable")
  end

  Given 'my auth token is not valid' do
    page.execute_script 'Coreon.application.get("session").set("auth_token", "xxxxxxxx", {silent: true})'
  end

  Then 'I should see the password prompt' do
    page.should have_css("#coreon-password-prompt")
  end

  When 'I enter "ei8ht?" for password' do
    fill_in "Password", with: "ei8ht?"
  end

  And 'click on "Proceed"' do
    click_on "Proceed"
  end

  When 'I enter "se7en!" for password' do
    fill_in "Password", with: "se7en!"
  end
end
