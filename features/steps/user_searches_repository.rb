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

  Given 'my auth token is not valid' do
    page.execute_script "Coreon.application.account.set('session', 'xxxxxxxxxxxx-0488d880-af3a-012f-5664-525400b5532a', {silent: true})"
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
