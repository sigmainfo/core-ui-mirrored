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
      @fieldset_definition = fieldset_with 'Key', 'definition'
      expect(@fieldset_definition).to be_visible
    end
  end

  step 'this fieldset contains a text area "VALUE"' do
    within @fieldset_definition do
      expect(page).to have_field 'Value', type: 'textarea'
    end
  end

  step 'this fieldset contains a select "LANGUAGE"' do
    within @fieldset_definition do
      expect(page).to have_field 'Language', type: 'select'
    end
  end

  step 'I see a fieldset with key "dangerous" within this section' do
    within @section do
      @fieldset_dangerous = fieldset_with 'Key', 'dangerous'
      expect(@fieldset_dangerous).to be_visible
    end
  end

  step 'this fieldset contains a checkbox "VALUE"' do
    within @fieldset_dangerous do
      expect(page).to have_field 'Value', type: 'checkbox'
    end
  end

  step 'this fieldset does not contain a select "LANGUAGE"' do
    within @fieldset_dangerous do
      expect(page).not_to have_field 'Language', type: 'select'
    end
  end

  step 'I fill "VALUE" for "definition" with "sucks blood; bat"' do
    within @fieldset_definition do
      fill_in 'Value', with: 'sucks blood; bat'
    end
  end

  step 'I select "English" as "LANGUAGE" for "definition"' do
    within @fieldset_definition do
      binding.pry
      select 'en', from: 'Language'
    end
  end
end
