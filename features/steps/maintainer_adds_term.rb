# encoding: utf-8
class Spinach::Features::MaintainerAddsTerm < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include Factory
  include Selectors
  include Resources


  step 'a concept "top hat" exists' do
    @concept = create_concept properties: [
      { key: "label", value: "top hat" }
    ]
  end

  step 'the repository defines a blueprint for terms' do
    @blueprint = blueprint(:term)
    @blueprint['clear'].delete
  end

  step 'that blueprint requires a property "status" of type "text"' do
    @blueprint['properties'].post property: {
      key: 'status',
      type: 'text',
      required: true
    }
  end

  step 'that blueprint allows a property "description" of type "text"' do
    @blueprint['properties'].post property: {
      key: 'description',
      type: 'text',
      required: false
    }
  end

  step 'that blueprint allows a property "notes" of type "text"' do
    @blueprint['properties'].post property: {
      key: 'notes',
      type: 'text',
      required: false
    }
  end

  step 'I click "Add term"' do
    click_link "Add term"
  end

  step 'I should see a set of term inputs with labels "Value", "Language"' do
    within ".term.create" do
      page.should have_field("Value")
      page.should have_field("Language")
    end
  end

  step 'I fill in "Value" with "high hat" within term inputs' do
    within ".term.create" do
      fill_in "Value", with: "high hat"
    end
  end

  step 'I fill in "Language" with "en" within term inputs' do
    within ".term.create" do
      fill_in "Language", with: "en"
    end
  end

  step 'I see a form "Create term"' do
    @form = page.find :form, 'Create term'
  end

  step 'I see a section "PROPERTIES" with this form' do
    within @form do
      @section = page.find :section, 'Properties'
      expect(@section).to be_visible
    end
  end

  step 'I see a fieldset "STATUS" within this section' do
    within @section do
      @fieldset = page.find :fieldset_with_title, "status"
      @status_fieldset = @fieldset
      expect(@fieldset).to be_visible
    end
  end

  step 'I see a fieldset "DESCRIPTION"' do
    within @section do
      @fieldset = page.find :fieldset_with_title, "description"
      @description_fieldset = @fieldset
      expect(@fieldset).to be_visible
    end
  end

  step 'this fieldset is empty' do
    within @fieldset do
      input = page.find('input')
      expect(input[:value]).to eql ''
    end
  end

  step 'I click "Add property" within term inputs' do
    within ".term.create" do
      click_link "Add property"
    end
  end

  step 'I should see a set of property inputs with labels "Key", "Value", "Language"' do
    within ".term.create .property" do
      page.should have_field("Key")
      page.should have_field("Value")
      page.should have_field("Language")
    end
  end

  step 'I fill in "Key" with "status" within property inputs' do
    within ".term.create .property" do
      fill_in "Key", with: "status"
    end
  end

  step 'I fill in "Value" with "pending" within property inputs' do
    within ".term.create .property" do
      fill_in "Value", with: "pending"
    end
  end

  step 'I fill in "STATUS" with "pending"' do
    within @fieldset do
      fill_in page.find('input')[:id], with: 'pending'
    end
  end

  step 'I fill in "DESCRIPTION" with "this is it"' do
    within @fieldset do
      fill_in page.find('input')[:id], with: 'this is it'
    end
  end

  step 'I select "English" for "LANGUAGE"' do
    within @fieldset do
      select 'English', from: page.find('select')[:id]
    end
  end

  step 'I see a dropdown with options "DESCRIPTION", "NOTES"' do
    @dropdown = page.find 'ul.options'
    @new_description = @dropdown.find 'li.option', text: 'description'
    expect(@new_description).to be_visible
    @new_notes = @dropdown.find 'li.option', text: 'notes'
      expect(@new_notes).to be_visible
  end

  step 'I click on "DESCRIPTION"' do
    @new_description.click
  end

  step 'I click "Create term"' do
    click_button "Create term"
  end

  step 'I should see a term "high hat" within language "EN"' do
    page.should have_css(".language.en .term .value", text: "high hat")
  end

  step 'I click "PROPERTIES" within term' do
    within ".language.en .term" do
      find("h3", text: "PROPERTIES").click
    end
  end

  step 'I should see a property "STATUS" for the term with value "pending"' do
    within '.language.en .term .properties' do
      sleep 1
      page.should have_css('th', text: 'STATUS')
      find('th', text: 'STATUS').find(:xpath, './following-sibling::td[1]').should have_text('pending')
    end
  end

  step 'I should see a property "DESCRIPTION" for the term with value "this is it"' do
    within '.language.en .term .properties' do
      sleep 1
      page.should have_css('th', text: 'DESCRIPTION')
      find('th', text: 'DESCRIPTION').find(:xpath, './following-sibling::td[1]').should have_text('this is it')
    end
  end

  step 'I should see a message \'Successfully created term "high hat".\'' do
    page.should have_css(".notification", text: 'Successfully created term "high hat".')
  end

  step 'I should not see "Create term"' do
    page.should have_no_button("Create term")
  end

  step 'this summary should contain "Failed to create term:"' do
    within "form.create.term" do
      page.find(".error-summary").should have_content("Failed to create term:")
    end
  end

  step 'this summary should contain "1 error on properties"' do
    within "form.create.term" do
      page.find(".error-summary").should have_content("1 error on properties")
    end
  end

  step 'I should see error "can\'t be blank" for term input "Language"' do
    within "form.create.term > .lang" do
      page.find_field("Language").find(:xpath, './following-sibling::*[contains(@class, "error-message")]').should have_content("can't be blank")
    end
  end

  step 'I should see error "can\'t be blank" for property input "Key" within term inputs' do
    within "form.create.term .property" do
      page.find_field("Key").find(:xpath, './following-sibling::*[contains(@class, "error-message")]').should have_content("can't be blank")
    end
  end

  step 'I click "Remove property" within term inputs' do
    within "form.create.term" do
      click_link "Remove property"
    end
  end

  step 'I should not see an error summary' do
    page.should have_no_css(".error-summary")
  end

  step 'I click "Cancel"' do
    click_link "Cancel"
  end

  step 'I should not see "high hat"' do
    page.should have_no_content("high hat")
  end

  step 'these term inputs should be empty' do
    within "form.term.create" do
      page.all("input,textarea").each { |input| input.value.should be_empty }
    end
  end

  step 'I should not see property inputs' do
    within "form.term.create" do
      page.should have_no_css(".property input")
    end
  end
end
