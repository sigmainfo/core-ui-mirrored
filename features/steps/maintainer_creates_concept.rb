# encoding: utf-8
class MaintainerCreatesConcept < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps

  step 'I have maintainer privileges' do
    page.execute_script 'Coreon.application.session.ability.set("role", "maintainer");'
  end

  step 'I visit the start page' do
    page.execute_script 'Backbone.history.navigate("/other");'
    page.execute_script 'Backbone.history.navigate("/", {trigger: true});'
  end

  step 'I click on "New concept"' do
    page.click_link "New concept"
  end

  step 'I do a search for "corpse"' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "corpse"
      find('input[type="submit"]').click
    end
  end

  step 'I do not have maintainer privileges' do
    page.execute_script 'Coreon.application.session.ability.set("role", "user");'
  end

  step 'I should not see "New concept"' do
    page.should have_no_link("New concept")
  end

#   step 'I should see a button "Create Concept"' do
#     page.should have_css ".button", text: "Create Concept"
#   end
# 
#   step 'I click on the create concept link' do
#     find('a.create-concept').click
#   end
# 
#   step 'I should be on the create concept page' do
#     current_path.should == "/concepts/create"
#   end
# 
#   step 'I should see title "<New Concept>"' do
#     page.should have_css "h2.label", text: "<New Concept>"
#   end
# 
#   step 'I should see a new concept node "<New Concept>" within the concept map' do
#     page.should have_css ".concept-node.new", text: "<New Concept>"
#   end
# 
#   step 'I should see an "Add Property" link' do
#     page.should have_css "a.add_property", text: "Add Property"
#   end
# 
#   step 'I should see an "Add Term" link' do
#     page.should have_css "a.add_term", text: "Add Term"
#   end
# 
#   step 'I should see a link to "create" the concept' do
#     page.should have_css ".create", "Create"
#   end
# 
#   step 'I should see a link to "cancel" the creation of the concept' do
#     page.should have_css ".cancel", "Cancel"
#   end
# 
#   step 'I should see "<New Concept>" being the current concept within the "Broader & Narrower" section' do
#     within ".concept-tree" do
#       page.should have_css ".section-toggle", "Broader & Narrower"
#       page.should have_css ".self", "<New Concept>"
#       page.should have_css ".super", ""
#       page.should have_css ".sub", ""
#     end
#   end
# 
#   step 'I click on "Add Term"' do
#     find('a.add_term').click
#   end
# 
#   step 'I should see two empty inputs for Term Value and Language' do
#     within ".create-term[3]" do
#       find_field("Term Value").value.should == ""
#       find_field("Language").value.should == ""
#     end
#   end
# 
#   step 'I should see a "Remove Term" link for the new term' do
#     within ".create-term[3]" do
#       page.should have_css "a.remove_term", text: "Remove Term"
#     end
#   end
# 
#   step 'I click on "Create"' do
#     find(".button.create").click
#     sleep 0.3
#   end
# 
#   step 'I should see a concept error message "Concept could not be saved" with "Terms had errors"' do
#     page.should have_css( ".errors p", text: "Concept could not be saved" )
#     page.should have_css( ".errors li", text: "Terms had errors" )
#   end
#   
#   step 'I should see term error messages "Please enter a Term Value" and "Please enter the Language of the Term"' do
#     page.should have_css( ".terms .value .error_message", text: "Please enter a Term Value" )
#     page.should have_css( ".terms .language .error_message", text: "Please enter the Language of the Term" )
#   end
#   
#   step 'I click on "Remove Term"' do
#     within ".create-term[3]" do
#       find("a.remove_term").click
#     end
#   end
# 
#   step 'I should not see the term inputs anymore' do
#     page.should have_no_css(".create-term[3]")
#   end
# 
#   step 'I click on "Add Property" link' do
#     find("a.add_property").click
#   end
# 
#   step 'I should see inputs for Property Key, Value and Language' do
#     within ".properties" do
#       find_field("Property Key").value.should == ""
#       find_field("Property Value").value.should == ""
#       find_field("Language").value.should == ""
#     end
#   end
# 
#   step 'I should see a concept error message "Concept could not be saved" with "Properties had errors"' do
#     page.should have_css( ".errors p", text: "Concept could not be saved" )
#     page.should have_css( ".errors li", text: "Properties had errors" )
#   end
#   
#   step 'I should see property error messages "Please enter a Property Key" and "Please enter a Property Value"' do
#     page.should have_css( ".properties .key .error_message", text: "Please enter a Property Key" )
#     page.should have_css( ".properties .value .error_message", text: "Please enter a Property Value" )
#   end
#   
#   step 'I click on the "Remove Property"' do
#     within ".properties" do
#       find("a.remove_property").click
#     end
#   end
# 
#   step 'I should not see the property input anymore' do
#     within ".properties" do
#       page.should have_no_css(".create-property")
#     end
#   end
# 
#   step 'I enter "label" as Property Key and "flowerpower" as Property Value' do
#     within ".create-property[3]" do
#       fill_in "Property Key", :with => 'label'
#       fill_in "Property Value", :with => 'flowerpower'
#       fill_in "Language", :with => 'en'
#     end
#   end
# 
#   step 'I enter "flower" as Term Value and "en" as Term Language' do
#     within ".create-term[3]" do
#       fill_in "Term Value", :with => 'hippies'
#       fill_in "Language", :with => 'en'
#     end
#   end
# 
#   step 'I should be redirected to the concept page of the newly created concept' do
#     sleep 0.2
#     current_path.should match "/concepts/[^/]+$"
#   end
# 
#   step 'I should see title "flowerpower"' do
#     page.should have_css "h2.label", text: "flowerpower"
#   end
end
