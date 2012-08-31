class UserDefinesTypeOfSearch < Spinach::FeatureSteps
  include AuthSteps

  Then 'I should see the hint "Search all" in the search input' do
    page.find("#coreon-search .hint").should have_content("Search all")
  end

  When 'I click on the triangle within the search input' do
    page.find("#coreon-search .toggle").click
  end

  Then 'I should see a dropdown with "All", "Definition", and "Terms"' do
    page.find("#coreon-search-target-select-dropdown").should be_visible
    options = []
    page.all("#coreon-search-target-select-dropdown li").each { |li| options << li.text }
    options.should == ["All", "Definition", "Terms"]
  end

  And '"All" should be selected' do
    page.all("#coreon-search-target-select-dropdown li").each do |li|
      if li.text == "All"
       li["class"].split(/\s+/).should include("selected")
      end
    end
  end

  When 'I click on "Terms"' do
    page.all("#coreon-search-target-select-dropdown li").each do |li|
      if li.text == "Terms"
       li.click
      end
    end
  end

  Then 'I should not see the dropdown' do
    page.should have_no_css("#coreon-search-target-select-dropdown")
  end

  But 'I should see the hint "Search by terms" in the search input' do
    page.find("#coreon-search .hint").should have_content("Search by terms")
  end

  And '"Terms" should be selected' do
    page.find("#coreon-search-target-select-dropdown li.selected").text.should == "Terms"
  end

  When 'I click outside the dropdown' do
    # reduce height temporarily to make el clickable
    page.execute_script('$("#coreon-search-target-select-dropdown").height(200)')
    page.find("#coreon-search-target-select-dropdown").click
    page.execute_script('$("#coreon-search-target-select-dropdown").height("")')
  end

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
    current_path.should =~ %r{^/concepts/search}
  end

  And 'the search type should be "terms"' do
    current_path.should =~ %r{^/concepts/search/terms}
  end

  And 'the query string should be "poet"' do
    require 'uri'
    URI.parse(current_url).query.should =~ /\bq=poet\b/
  end
end
