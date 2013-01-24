require 'uri'

class UserDefinesTypeOfSearch < Spinach::FeatureSteps
  include AuthSteps

  Then 'I should see the hint "Search all" in the search input' do
    page.find("#coreon-search .hint").should have_content("Search all")
  end

  When 'I click on the triangle within the search input' do
    page.find("#coreon-search .toggle").click
  end

  Then 'I should see a dropdown with "All", "Concepts by Definition", and "Concepts by Terms"' do
    page.find("#coreon-search-target-select-dropdown").should be_visible
    options = []
    page.all("#coreon-search-target-select-dropdown li").each { |li| options << li.text }
    options.should == ["All", "Concepts by Definition", "Concepts by Terms"]
  end

  And '"All" should be selected' do
    page.all("#coreon-search-target-select-dropdown li").each do |li|
      if li.text == "All"
       li["class"].split(/\s+/).should include("selected")
      end
    end
  end

  When 'I click on "Concepts by Terms"' do
    page.all("#coreon-search-target-select-dropdown li").each do |li|
      if li.text == "Concepts by Terms"
       li.click
      end
    end
  end

  Then 'I should not see the dropdown' do
    page.should have_no_css("#coreon-search-target-select-dropdown")
  end

  But 'I should see the hint "Search concepts by terms" in the search input' do
    page.find("#coreon-search .hint").should have_content("Search concepts by terms")
  end

  And '"Concepts by Terms" should be selected' do
    page.find("#coreon-search-target-select-dropdown li.selected").text.should == "Concepts by Terms"
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

  Then 'I should be on the search concepts page with target "terms and query "poet' do
    current_path.should == "/concepts/search/terms/poet"
  end
end
