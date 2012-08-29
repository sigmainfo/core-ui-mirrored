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
    pending 'step not implemented'
  end

  Then 'I should not see the dropdown' do
    pending 'step not implemented'
  end

  But 'I should see the hint "Search by terms" in the search input' do
    pending 'step not implemented'
  end

  And '"Terms" should be selected' do
    pending 'step not implemented'
  end

  When 'I click outside the dropdown' do
    pending 'step not implemented'
  end

  When 'I enter "poet" in the search field' do
    pending 'step not implemented'
  end

  And 'I press enter' do
    pending 'step not implemented'
  end

  Then 'I should be on the search concepts page' do
    pending 'step not implemented'
  end

  And 'the search type should be "terms"' do
    pending 'step not implemented'
  end

  And 'the query string should be "poet"' do
    pending 'step not implemented'
  end
end
