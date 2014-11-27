class Spinach::Features::MaintainerEditsTerm < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include Factory
  include Selectors
  include Resources

  step 'the repository defines a blueprint for terms' do
    @blueprint = blueprint(:term)
    @blueprint['clear'].delete
  end

  step 'that blueprint requires a property "status" of type "text"' do
    @blueprint['properties'].post property: {
      key: 'status',
      type: 'text',
      required: true,
      default: ''
    }
  end

  step 'that blueprint allows a property "public" of type "boolean"' do
    @blueprint['properties'].post property: {
      key: 'public',
      type: 'boolean',
      required: false,
      default: false,
      labels: ['yes', 'no']
    }
  end

  step 'a concept with an English term "ten-gallon hat" exists' do
    @concept = create_concept({})
    @term = create_concept_term @concept, lang: "en", value: "ten-gallon hat"
  end

  step 'this term has a property "notice" of "TODO: translate"' do
    @prop = create_concept_term_property @concept, @term, key: "notice", value: "TODO: translate"
  end

  step 'this term has a property "public" set to false' do
    @prop = create_concept_term_property @concept, @term, key: "public", value: false
  end

  step 'this term has a property "status" set to "pending"' do
    @prop = create_concept_term_property @concept, @term, key: 'status', value: 'pending'
  end

  step 'I click "Edit term" within term "ten-gallon hat"' do
    page.find(".term .value", text: "ten-gallon hat").find(:xpath, './parent::*').find(".edit a", text: "Edit term").click
  end

  step 'I see a form "Save term"' do
    binding.pry
    @form = page.find :form, 'Save term'
  end

  step 'I see a section "PROPERTIES" with this form' do
    within @form do
      @section = page.find :section, 'Properties'
      expect(@section).to be_visible
    end
  end

  step 'I should see a set of term inputs with labels "Value", "Language"' do
    within(".terms") do
      page.should have_field("Value")
      page.should have_field("Language")
    end
  end

  step 'I should see "ten-gallon hat" for input "Value"' do
    within(".terms") do
      page.find_field("term-value").value.should == "ten-gallon hat"
    end
  end

  step 'I should see "en" for input "Language"' do
    within(".terms") do
      page.find_field("Language").value.should == "en"
    end
  end

  step 'I fill in "Value" with "Cowboyhut" within term inputs' do
    within(".terms") do
      fill_in "Value", with: "Cowboyhut"
    end
  end

  step 'I fill in "Language" with "de" within term inputs' do
    within(".terms") do
      fill_in "Language", with: "de"
    end
  end

  step 'I see a fieldset "STATUS" within this section' do
    within @section do
      @fieldset = page.find :fieldset_with_title, "status"
      @status_fieldset = @fieldset
      expect(@fieldset).to be_visible
    end
  end

  step 'I see a fieldset "PUBLIC" within this section' do
     within @section do
      @fieldset = page.find :fieldset_with_title, "public"
      @public_fieldset = @fieldset
      expect(@fieldset).to be_visible
    end
  end

  step 'I see a fieldset "NOTICE" within this section' do
     within @section do
      @fieldset = page.find :fieldset_with_title, "notice"
      @public_fieldset = @fieldset
      expect(@fieldset).to be_visible
    end
  end

  step 'I fill in "STATUS" with "pending"' do
    within @fieldset do
      fill_in page.find('input')[:id], with: 'pending'
    end
  end

  step 'I fill in "STATUS" with "ready"' do
    within @fieldset do
      fill_in page.find('input')[:id], with: 'ready'
    end
  end

  step 'this fieldset has a checked radio option "no"' do
    within @fieldset do
      expect(@fieldset).to have_field 'no', checked: true
    end
  end

  step 'this fieldset has a value "ready"' do
    within @fieldset do
      input = find 'input[type=text]'
      expect(input[:value]).to eql 'ready'
    end
  end

  step 'this fieldset has a value "TODO: translate"' do
    within @fieldset do
      input = find 'input[type=text]'
      expect(input[:value]).to eql 'TODO: translate'
    end
  end

  step 'this fieldset is empty' do
    within @fieldset do
      input = page.find('input')
      expect(input[:value]).to eql ''
    end
  end

  step 'I click "Add property" within term inputs' do
    within(".terms") do
      click_link "Add property"
    end
  end

  step 'I fill in "Key" with "status" within property inputs' do
    within(".terms .term .properties") do
      fill_in "Key", with: "status"
    end
  end

  step 'I fill in "Value" with "pending" within property inputs' do
    within(".terms .term .properties") do
      fill_in "Value", with: "pending"
    end
  end

  step 'I should see a set of property inputs with labels "Key", "Value", "Language"' do
    within(".terms .term .property") do
      page.should have_field("Key")
      page.should have_field("Value")
      page.should have_field("Language")
    end
  end

  step 'I click "Save term"' do
    within(".terms") do
      click_link_or_button "Save term"
    end
  end

  step 'I should see a term "Cowboyhut" within language "DE"' do
    page.should have_css(".language.de .term .value", text: "Cowboyhut")
  end

  step 'I click "PROPERTIES" within term' do
    within ".terms" do
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
      page.find_field("Key").value.should == "notice"
    end
  end

  step 'I should see "TODO: translate" for property input "Value"' do
    within ".term .property" do
      page.find_field("Value").value.should == "TODO: translate"
    end
  end

  step 'I click "Remove property"' do
    within ".terms" do
      click_link "Remove property"
    end
  end

  step 'I click "Remove public"' do
    within @fieldset do
      click_link "Remove public"
    end
  end

  step 'I click "Remove notice"' do
    within @fieldset do
      click_link "Remove notice"
    end
  end

  step 'the property inputs should be disabled' do
    within ".term .property.delete" do
      page.all("input,textarea,button").length.should == page.all(":disabled").length
    end
  end

  step 'I should see a confirmation dialog warning that one property will be deleted' do
    page.find("#coreon-modal .confirm").should have_content("delete 1 properties")
  end

  step 'I should see a message \'Successfully saved term "ten-gallon hat".\'' do
    page.should have_css(".notification", text: 'Successfully saved term "ten-gallon hat".')
  end

  step 'I should see a term "ten-gallon hat" within language "EN"' do
    page.should have_css(".language.en .term .value", text: "ten-gallon hat")
  end

  step 'I should not see "PROPERTIES" within that term' do
    within ".terms" do
      page.should have_no_css("h2", text: "PROPERTIES")
    end
  end

  step 'I click "Edit term"' do
    within ".terms" do
      click_link "Edit term"
    end
  end

  step 'I fill in "Value" with "Stetson" within term inputs' do
    within(".terms") do
      fill_in "Value", with: "Stetson"
    end
  end

  step 'I fill in "Language" with "" within term inputs' do
    within(".terms") do
      fill_in "Language", with: ""
    end
  end

  step 'I fill in "Key" with "" within property inputs' do
    within(".terms") do
      fill_in "Key", with: ""
    end
  end

  step 'this summary should contain "Failed to save term:"' do
    page.find("form .error-summary").should have_content("Failed to save term:")
  end

  step 'this summary should contain "1 error on lang"' do
    page.find("form .error-summary").should have_content("1 error on lang")
  end

  step 'this summary should contain "2 errors on properties"' do
    page.find("form .error-summary").should have_content("2 errors on properties")
  end

  step 'I should see error "can\'t be blank" for term input "Language"' do
    page.should have_css(".term .lang .error-message", text: "can\'t be blank")
  end

  step 'I should see error "can\'t be blank" for property input "Key" within term inputs' do
    page.should have_css(".term .property .key .error-message", text: "can\'t be blank")
  end

  step 'I fill in "Language" with "en" within term inputs' do
    within(".terms") do
      fill_in "Language", with: "en"
    end
  end

  step 'I should see a term "Stetson" within language "EN"' do
    page.should have_css(".language.en .term .value", text: "Stetson")
  end

  step 'I should not see an error summary' do
    page.should have_no_css("form .error-summary")
  end

  step 'I should see a message \'Successfully saved term "Stetson".\'' do
    page.should have_css(".notification", text: 'Successfully saved term "Stetson".')
  end

  step 'I fill in "Value" with "high hat" within term inputs' do
    within(".terms") do
      fill_in "term-value", with: "high hat"
    end
  end

  step 'I click "Reset"' do
    within(".terms") do
      click_link_or_button "Reset"
    end
  end

  step 'I should see exactly one set of property inputs' do
    page.find(".terms .term .properties .property")
  end

  step 'I should see exactly two sets of property inputs' do
    properties = page.all(".terms .term .properties .property")
    expect(properties.size).to eql 2
  end

  step 'I should see "Save term"' do
    within(".terms") do
      page.should have_button("Save term")
    end
  end

  step 'I click "Cancel"' do
    within(".terms") do
      click_link_or_button "Cancel"
    end
  end

  step 'I should not see "high hat"' do
    within(".terms") do
      page.should have_no_css(".language.en .term .value", text: "high hat")
    end
  end
end
