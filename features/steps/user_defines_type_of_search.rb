class UserDefinesTypeOfSearch < Spinach::FeatureSteps
  include AuthSteps

  Then 'I should see the hint "Search all" in the search input' do
    pending 'step not implemented'
  end

  When 'I click on the triangle within the search input' do
    pending 'step not implemented'
  end

  Then 'I should see a dropdown with "All", "Definition", and "Terms"' do
    pending 'step not implemented'
  end

  And '"All" should be selected' do
    pending 'step not implemented'
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
