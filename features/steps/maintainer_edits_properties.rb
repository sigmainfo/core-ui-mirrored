class Spinach::Features::MaintainerEditsProperties < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include Resources
  include Selectors

  step 'the repository defines a blueprint for concepts' do
    @blueprint = blueprint(:concept)
    @blueprint['clear'].delete
  end

  step 'that blueprint defines a property "definition" of type "multiline text"' do
    @blueprint['properties'].post property: { key: 'definition', type: 'multiline_text' }
  end

  step 'that blueprint defines a property "dangerous" of type "boolean"' do
    @blueprint['properties'].post property: { key: 'dangerous', type: 'boolean' }
  end

  step 'I click on "New concept"' do
    click_link "New concept"
  end

  step 'I see a section "PROPERTIES" within the form "Create concept"' do
    within :form, 'Create concept' do
      @section = page.find :section, 'Properties'
      expect(@section).to be_visible
    end
  end

  step 'I see a fieldset with key "definition" within this section' do
    within @section do
      @fieldset = fieldset_with 'Key', 'definition'
      expect(@fieldset).to be_visible
    end
  end

  step 'this fieldset contains a text area "VALUE"' do
    within @fieldset do
      expect(page).to have_field 'Value', type: 'textarea'
    end
  end

  step 'this fieldset contains a select "LANGUAGE"' do
    within @fieldset do
      expect(page).to have_field 'Language', type: 'select'
    end
  end
end
