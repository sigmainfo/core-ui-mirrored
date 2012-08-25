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

  Then 'I should be on the search concepts page' do
    current_path.should == "/concepts/search"
  end

  And 'I should see "poet" as the query string' do
    require 'uri'
    URI.parse(current_url).query.should =~ /\bq=poet\b/
  end

  Then 'I should see a progress indicator' do
    find("#coreon-progress-indicator")["class"].should == "busy"
  end

  Given 'the repository is not available' do
    page.execute_script "Coreon.application.account.set('graph_root', 'https://this.goes.nowhere/')"
  end

  Then 'I should see an error "Service is currently unavailable"' do
    find("#coreon-notifications .error").should have_content "Service is currently unavailable"
  end
end
