# encoding: utf-8
class MaintainerCreatesConcept < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps

  step 'I should see a button "CREATE CONCEPT"' do
    page.should have_css(".button", text: "CREATE CONCEPT")
  end

#  And 'I should see a create concept link' do
#    pending "need a view"
#  end

  And 'I click on the create concept link' do
    find('a.create-concept').click
  end

  Then 'I should be on the create concept page' do
    current_path.should == "/concepts/create"
  end

  And 'I click on the "cancel" link' do
    find('a.cancel').click
  end
  

end
