class Spinach::Features::MaintainerEditsTerm < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps

  step 'a concept with an English term "ten-gallon hat" exists' do
    @concept = create_concept
    @term = create_concept_term @concept, lang: "en", value: "ten-gallon hat"
  end

  step 'this term has a property "notice" of "TODO: translate"' do
    @prop = create_concept_term_property @concept, @term, key: "parts of speach", value: "noun"
  end

  step 'I am on the show concept page of this concept' do
    page.execute_script "Backbone.history.navigate('concepts/#{@concept['_id']}', { trigger: true })"
  end

  step 'I click "Edit term" within term "ten-gallon hat"' do
    page.find(".term .value", text: "ten-gallon hat").find(:xpath, './parent::*').find(".edit a", text: "Edit term").click
  end

  step 'I should see a set of term inputs with labels "Value", "Language"' do
    within(".term") do
      page.should have_field("Value")
      page.should have_field("Language")
    end
  end

  step 'I should see "ten-gallon hat" for input "Value"' do
    within(".term") do
      page.find_field("Value").text.should == "ten-gallon hat"
    end
  end

  step 'I should see "en" for input "Language"' do
    within(".term") do
      page.find_field("Language").text.should == "Language"
    end
  end

  step 'I fill in "Value" with "Cowboyhut" within term inputs' do
    within(".term") do
      fill_in "Value", with: "Cowboyhut"
    end
  end

  step 'I fill in "Language" with "de" within term inputs' do
    within(".term") do
      fill_in "Language", with: "de"
    end
  end

  step 'I click "Add property" within term inputs' do
    within(".term") do
      click_link "Add property"
    end
  end

  step 'I fill in "Key" with "status" within property inputs' do
    within(".term .property") do
      fill_in "Key", with: "status"
    end
  end

  step 'I fill in "Value" with "pending" within property inputs' do
    within(".term .property") do
      fill_in "Value", with: "pending"
    end
  end

  step 'I should see a set of property inputs with labels "Key", "Value", "Language"' do
    within(".term .property") do
      page.should have_field("Key")
      page.should have_field("Value")
      page.should have_field("Language")
    end
  end

  step 'I click "Save term"' do
    within(".term") do
      click_link "Save term"
    end
  end

  step 'I should see a term "Cowboyhut" within language "DE"' do
    page.should have_css(".language.de .term .value", text: "Cowboyhut")
  end

  step 'I click "PROPERTIES" within term' do
    within ".term" do
      find("h3", text: "PROPERTIES").click
    end
  end

  step 'I should see a property "STATUS" for the term with value "pending"' do
    within ".term .properties" do
      find("th", text: "STATUS").find(:xpath, "./following-sibling::td[1]").should have_text("pending")
    end
  end

  step 'I should see a message \'Successfully saved term "Cowboyhut".\'' do
    page.should have_css(".notification", text: 'Successfully saved term "Cowboyhut".')
  end

  step 'I should see "Cowboyhut" within the title' do
    page.should have_css(".concept h2", text: "Cowboyhut")
  end

  step 'I should not see "Save term"' do
    page.should have_no_button("Save term")
  end

  step 'I should see "notice" for property input "Key"' do
    within ".term .property" do
      page.find_field("Key").text.should == "notice"
    end
  end

  step 'I should see "TODO: translate" for property input "Value"' do
    within ".term .property" do
      page.find_field("Value").text.should == "TODO: translate"
    end
  end

  step 'I click "Remove property" within property inputs' do
    within ".term" do
      click_link "Remove property"
    end
  end

  step 'the property inputs should be disabled' do
    within ".term .property.delete" do
      page.all("input").attr("disabled").should == true
    end
  end

  step 'I should see a confirmation dialog "This will delete 1 property permanently."' do
    page.find("#coreon-modal .confirm").should have_content("delete 1 property")
  end

  step 'I should see a message \'Successfully saved term "ten-gallon hat".\'' do
    page.should have_css(".notification", text: 'Successfully saved term "ten-gallon hat".')
  end

  step 'I should see a term "ten-gallon hat" within language "DE"' do
    page.should have_css(".language.de .term .value", text: "ten-gallon hat")
  end

  step 'I should not see "PROPERTIES" within that term' do
    within ".term" do
      page.should have_no_css("h2", text: "PROPERTIES")
    end
  end

  step 'I click "Edit term"' do
    within ".term" do
      click_link "Edit term"
    end
  end

  step 'I fill in "Value" with "Stetson" within term inputs' do
    within(".term") do
      fill_in "Value", with: "Stetson"
    end
  end

  step 'I fill in "Language" with "" within term inputs' do
    within(".term") do
      fill_in "Language", with: ""
    end
  end

  step 'I fill in "Key" with "" within property inputs' do
    within(".term") do
      fill_in "Key", with: ""
    end
  end

  step 'this summary should contain "Failed to save term:"' do
    pending 'step not implemented'
  end

  step 'this summary should contain "1 error on language"' do
    pending 'step not implemented'
  end

  step 'this summary should contain "1 error on properties"' do
    pending 'step not implemented'
  end

  step 'I should see error "can\'t be blank" for term input "Language"' do
    pending 'step not implemented'
  end

  step 'I should see error "can\'t be blank" for property input "Key" within term inputs' do
    pending 'step not implemented'
  end

  step 'I click "Remove property" within term inputs' do
    pending 'step not implemented'
  end

  step 'I fill in "Language" with "en" within term inputs' do
    pending 'step not implemented'
  end

  step 'I should see a term "Stetson" within language "EN"' do
    page.should have_css(".language.en .term .value", text: "Stetson")
  end

  step 'I should not see an error summary' do
    pending 'step not implemented'
  end

  step 'I should see a message \'Successfully saved term "high hat".\'' do
    pending 'step not implemented'
  end

  step 'I fill in "Value" with "high hat" within term inputs' do
    pending 'step not implemented'
  end

  step 'I click "Reset"' do
    pending 'step not implemented'
  end

  step 'I should see "ten-gallon hat" for "Value"' do
    pending 'step not implemented'
  end

  step 'I should see exactly one set of property inputs' do
    pending 'step not implemented'
  end

  step 'I should see "Save term"' do
    pending 'step not implemented'
  end

  step 'I click "Cancel"' do
    pending 'step not implemented'
  end

  step 'I should not see "high hat"' do
    pending 'step not implemented'
  end
end
