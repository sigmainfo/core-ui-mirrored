# encoding: utf-8
class MaintainerEditsConcept < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include SearchSteps
  include Api::Graph::Factory


  step 'a concept with property "label" of "handgun" exists' do
    @concept = create_concept properties: [{key: 'label', value: 'handgun'}]
  end

  step 'I visit the page of this concept' do
    page.execute_script "Backbone.history.navigate('concepts/#{@concept['_id']}', { trigger: true })"
  end

  step 'I should see edit buttons' do
    page.should have_css(".concept .properties .edit-properties")
  end

  step 'I should not see the edit concept button' do
    page.should have_no_css(".concept .edit-concept")
  end

  step 'I should not see edit buttons' do
    page.should have_no_css(".concept .properties .edit-properties")
  end

  step 'I click "Edit properties"' do
    page.find(".edit-properties").click
  end

  step 'I should see a properties form' do
    page.should have_css("form.concept.update")
  end

  step 'I should see no properties form' do
    page.should_not have_css("form.concept.update")
  end

  step 'I click "reset"' do
    page.find(".submit .reset").click
  end

  step 'I click "cancel"' do
    page.find(".submit .cancel").click
  end

  step 'I click "Save concept"' do
    page.find('form.concept.update [type="submit"]').click
  end

  step 'I click "Remove property"' do
    page.find(".remove-property").click
  end

  step 'I click "Remove property" on the new entry' do
    page.all(".remove-property").last.click
  end

  step 'I click "Add property"' do
    page.find(".add-property").click
  end

  step 'I should see the property marked as deleted' do
    page.should have_css(".property.delete")
  end

  step 'I should see no property marked as deleted' do
    page.should have_css(".property")
    page.should_not have_css(".property.delete")
  end

  step 'I should see a new property' do
    page.all(".property").length.should == 2
  end

  step 'I should see only one property' do
    page.all(".property").length.should == 1
  end

  step 'I should see a form with key, value and language fields' do
    page.should have_css(".properties.edit .input.key input")
    page.should have_css(".properties.edit .input.value input")
    page.should have_css(".properties.edit .input.lang input")
  end

  step 'I should see the key "label" and value "handgun"' do
    page.find_field("Key").value.should == "label"
    page.find_field("Value").value.should == "handgun"
  end

  step 'I should see a property "LABEL" with value "obsolescense"' do
    page.should have_css(".properties th", text: "LABEL")
    page.find(:xpath, "//th[text() = 'label']/following-sibling::td").text.should == "obsolescense"
  end

  step 'I change "Key" of property to ""' do
    fill_in "Key", with: ""
  end

  step 'I should not see an error summary' do
    page.should have_no_css("form .error-summary")
  end

  step 'I should see error "can\'t be blank" for property input "Key"' do
    page.should have_css(".property .key .error-message", text: "can\'t be blank")
  end

  step 'this summary should contain "Failed to save concept:"' do
    page.find("form .error-summary").should have_content("Failed to save concept:")
  end

  step 'this summary should contain "1 error on properties"' do
    page.find("form .error-summary").should have_content("1 error on properties")
  end

  step 'I change "Value" of property to "obsolescense"' do
    fill_in "Value", with: "obsolescense"
  end

  step 'I should see a confirmation dialog warning that one property will be deleted' do
    page.find("#coreon-modal .confirm").should have_content("delete 1 properties")
  end
end
