module SearchSteps
  include Spinach::DSL

  When 'I enter "poet" in the search field' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "poet"
    end
  end

  When 'I enter "poe" in the search field' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "poe"
    end
  end

  And 'I click the search button' do
    within "#coreon-search" do
      find('input[type="submit"]').click
    end
  end

  Then 'I should be on the search result page' do
    current_path.should == "/search"
  end

  And 'I should see the query "poet" within the navigation' do
    require 'uri'
    URI.parse(current_url).query.should =~ /\bq=poet\b/
  end
end
