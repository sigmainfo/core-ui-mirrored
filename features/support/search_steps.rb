module SearchSteps
  include Spinach::DSL

  When 'I search for "panopticum"' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "panopticum"
      find('input[type="submit"]').click
    end
  end

  When 'I enter "poet" in the search field' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "poet"
    end
  end

  When 'I enter "gun" in the search field' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "gun"
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

  When 'I search for "handgun"' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "handgun"
      find('input[type="submit"]').click
    end
  end

  Then 'I should be on the search result page' do
    current_path.should =~ %r|^/#{@repository.id}/search|
  end

  And 'I should see the query "poet" within the navigation' do
    current_path.should =~ %r|/poet$|
  end
end
