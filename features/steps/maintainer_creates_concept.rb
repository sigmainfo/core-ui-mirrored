# encoding: utf-8
class MaintainerCreatesConcept < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps

  step 'I should see a button "CREATE CONCEPT"' do
    page.should have_css(".button", text: "CREATE CONCEPT")
  end

  step 'I click on the create concept link' do
    find('a.create-concept').click
  end

  step 'I should be on the create concept page for "gun"' do
    current_path.should == "/concepts/create/gun"
  end

  step 'I should see title "gun"' do
    page.should have_css("h2.label", text: "gun")
  end

  step 'I should see an "Add Property" link' do
    page.should have_css("h3.add_property", text: "Add property")
  end

  step 'I should see an "Add Term" link' do
    page.should have_css("h3.add_term", text: "Add term")
  end

  step 'I should see a link to "create" the concept' do
    page.should have_css(".create", "Create")
  end

  step 'I should see a link to "cancel" the creation of the concept' do
    page.should have_css(".cancel", "Cancel")
  end

  step 'I should see an input for term value with "gun"' do
    find('.input.value input').value.should == "gun"
  end

#  step 'I should see an input for term value with "gun"' do
#    find('div.input.value input').value.should == "gun"
#  end

#  And 'I click on the "cancel" link' do
#    find('a.cancel').click
#  end
  

end
