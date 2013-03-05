# encoding: utf-8
class MaintainerCreatesConcept < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps

  step 'I should see a button "Create Concept"' do
    page.should have_css(".button", text: "Create Concept")
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
    page.should have_css("a.add_property", text: "Add Property")
  end

  step 'I should see an "Add Term" link' do
    page.should have_css("a.add_term", text: "Add Term")
  end

  step 'I should see a link to "create" the concept' do
    page.should have_css(".create", "Create")
  end

  step 'I should see a link to "cancel" the creation of the concept' do
    page.should have_css(".cancel", "Cancel")
  end

  step 'I should see an input for term value with "gun"' do
    within ".create-term:first" do
      find_field("Term Value").value.should == "gun"
    end
  end

  step 'I should see an input "language" filled with the users search language' do
    within ".create-term:first" do
      find_field("Language").value.should == "en"
    end
  end

  step 'I should see a "Remove Term" link' do
    within ".create-term:first" do
      page.should have_css("a.remove_term", text: "Remove Term")
    end
  end

  step 'I should see an "Add Property" link for the term' do
    within ".create-term:first" do
      page.should have_css("a.add_term_property", text: "Add Property")
    end
  end

  step 'I enter "flower" into the term value field' do
    within ".create-term:first" do
      fill_in "Term Value", :with => 'flower'
      fill_in "Language", :with => 'en'
    end
  end

  step 'I should see title "flower"' do
    page.should have_css "h2.label", text: "flower"
  end

  step 'I click on "Add Term"' do
    find('a.add_term').click
  end

  step 'I should see two new empty inputs for Term Value and Language' do
    within ".create-term[2]" do
      find_field("Term Value").value.should == ""
      find_field("Language").value.should == ""
    end
  end

  step 'I should see a "Remove Term" link for the new term' do
    within ".create-term[2]" do
      page.should have_css "a.remove_term", text: "Remove Term"
    end
  end
  
  step 'I click on "Remove Term"' do
    within ".create-term[2]" do
      find("a.remove_term").click
    end
  end

  step 'I should not see the term inputs anymore' do
    page.should have_no_css(".create-term[2]")
  end

  step 'I click on "Add Property" link' do
    find("a.add_property").click
  end

  step 'I should see inputs for Property Key, Value and Language' do
    within ".concept > .properties" do
      find_field("Property Key").value.should == ""
      find_field("Property Value").value.should == ""
      find_field("Language").value.should == ""
    end
  end

  step 'I enter "label" as Property Key and "flowerpower" as Property Value' do
    within ".create-property:first" do
      fill_in "Property Key", :with => 'label'
      fill_in "Property Value", :with => 'flowerpower'
    end
  end
  
  step 'I should see title "flowerpower"' do
    page.should have_css "h2.label", text: "flower"
  end



end
