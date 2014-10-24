class Spinach::Features::MaintainerEditsProperties < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include Resources
  include Selectors

  def concept
    @concept ||= JSON.parse concepts.post concept: {}
  end

  step 'the repository defines a blueprint for concepts' do
    @blueprint = blueprint(:concept)
    @blueprint['clear'].delete
  end

  step 'that blueprint requires a property "short description" of type "text"' do
    @blueprint['properties'].post property: {
      key: 'short description',
      type: 'text',
      required: true
    }
  end

  step 'that blueprint requires a property "dangerous" of type "boolean"' do
    @property_attrs = {
      key: 'dangerous',
      type: 'boolean',
      required: true
    }
  end

  step 'that blueprint requires a property "tags" of type "multiselect picklist"' do
    @property_attrs = {
      key: 'tags',
      type: 'multiselect_picklist',
      required: true
    }
  end

  step 'that property defines labels "yes" and "no"' do
    @property_attrs[:labels] = ["yes", "no"]
    @blueprint['properties'].post property: @property_attrs
  end

  step 'that property allows values: "cool", "night life", "diet"' do
    @property_attrs[:values] = ["cool", "night life", "diet"]
    @blueprint['properties'].post property: @property_attrs
  end

  step 'that blueprint allows a property "alias" of type "text"' do
    @blueprint['properties'].post property: {
      key: 'alias',
      type: 'text',
      required: false
    }
  end

  step 'that blueprint allows a property "definition" of type "multiline text"' do
    @blueprint['properties'].post property: {
      key: 'definition',
      type: 'multiline_text',
      required: false
    }
  end

  step 'a concept "Bloodbath" exists' do
    concepts["#{concept['id']}/properties"].post property: { key: 'label', value: 'Bloodbath' }
  end

  step 'I click on "New concept"' do
    click_link "New concept"
  end

  step 'I edit that concept' do
    visit "/#{current_repository.id}/concepts/#{concept['id']}"
    click_link "Edit mode"
  end

  step 'I see a section "PROPERTIES" within the form "Create concept"' do
    @form = page.find :form, 'Create concept'
    within @form do
      @section = page.find :section, 'Properties'
      expect(@section).to be_visible
    end
  end

  step 'I see a section "PROPERTIES"' do
    @section = page.find :section, 'Properties'
    expect(@section).to be_visible
  end

  step 'I click on "Edit properties"' do
    click_link "Edit properties"
  end

  step 'I see a form "Save concept"' do
    @form = page.find :form, 'Save concept'
    expect(@form).to be_visible
  end

  step 'I see a fieldset "SHORT DESCRIPTION" within this section' do
    within @section do
      @fieldset = page.find :fieldset_with_title, "short description"
      @short_descr_fieldset = @fieldset
      expect(@fieldset).to be_visible
    end
  end

  step 'I see a fieldset "DANGEROUS" within this section' do
    within @section do
      @fieldset = page.find :fieldset_with_title, "dangerous"
      @dangerous_fieldset = @fieldset
      expect(@fieldset).to be_visible
    end
  end

  step 'I see a fieldset "TAGS" within this form' do
    within @form do
      @fieldset = page.find :fieldset_with_title, "tags"
      @tags_fieldset = @fieldset
      expect(@fieldset).to be_visible
    end
  end

  step 'I do not see a fieldset "ALIAS" or "DEFINITION"' do
    within @section do
      expect(page).to_not have_selector :fieldset_with_title, "definition"
    end
  end

  step 'this fieldset contains a text input' do
    within @fieldset do
      expect(page).to have_selector 'input[type=text]'
    end
  end

  step 'this fieldset contains a select "LANGUAGE"' do
    within @fieldset do
      expect(page).to have_selector 'select'
    end
  end

  step 'this fieldset contains radio buttons "yes" and "no"' do
    within @fieldset do
      expect(page).to have_field 'yes', type: 'radio'
      expect(page).to have_field 'no', type: 'radio'
    end
  end

  step 'this fieldset does not contain a select "LANGUAGE"' do
    within @fieldset do
      expect(page).not_to have_selector 'select'
    end
  end

  step 'this fieldset contains checkboxes for "cool", "night life", "diet"' do
    within @fieldset do
      expect(page).to have_field 'cool', type: 'checkbox'
      expect(page).to have_field 'night life', type: 'checkbox'
      expect(page).to have_field 'diet', type: 'checkbox'
    end
  end

  step 'I fill in "SHORT DESCRIPTION" with "sucks blood; bat"' do
    @fieldset = @short_descr_fieldset
    within @fieldset do
      fill_in page.find('input')[:id], with: 'sucks blood; bat'
    end
  end

  step 'I select "English" for "LANGUAGE"' do
    within @fieldset do
      select 'English', from: page.find('select')[:id]
    end
  end

  step 'I select "no" for "DANGEROUS"' do
    within @dangerous_fieldset do
      choose "no"
    end
  end

  step 'I click on "Add property" within this form' do
    within @form do
      click_link "Add property"
    end
  end

  step 'I see a dropdown with options "ALIAS", "DEFINITION"' do
    @dropdown = page.find 'ul.options'
    @new_alias = @dropdown.find 'li.option', text: 'alias'
    expect(@new_alias).to be_visible
    @new_definition = @dropdown.find 'li.option', text: 'definition'
    expect(@new_definition).to be_visible
  end

  step 'I click on "DEFINITION"' do
    @new_definition.click
  end

  step 'I see a fieldset "DEFINITION"' do
    @fieldset = page.find :fieldset_with_title, "definition"
    expect(@fieldset).to be_visible
  end

  step 'I fill in "Corpse that drinks blood of the living." for "DEFINITION"' do
    within @fieldset do
      fill_in page.find('textarea')[:id], with: 'Corpse that drinks blood of the living.'
    end
  end

  step 'I select "None" for "LANGUAGE"' do
    within @fieldset do
      select 'None', from: page.find('select')[:id]
    end
  end

  step 'I check "cool" and "night life"' do
    within @fieldset do
      check 'cool'
      check 'night life'
    end
  end

  step 'I click "Create concept"' do
    click_button "Create concept"
  end

  step 'I click "Save concept"' do
    click_button "Save concept"
  end

  step 'I see a listing "PROPERTIES" within the concept header' do
    expect(page).to have_css ".concept .properties"
  end

  step 'I see a property "SHORT DESCRIPTION" with English value "sucks blood; bat"' do
    within :table_row, 'short description' do
      expect(page).to have_css "td .value", text: 'sucks blood; bat'
    end
  end

  step 'I see a property "DANGEROUS" with value "no"' do
    within :table_row, 'dangerous' do
      expect(page).to have_css "td .value", text: 'no'
    end
  end

  step 'I see a "DEFINITION" with "Corpse that drinks blood of the living."' do
    within :table_row, 'definition' do
      expect(page).to have_css "td .value", text: 'Corpse that drinks blood of the living.'
    end
  end

  step 'I see a property "TAGS" with values "cool", "night life" only' do
    tags_row = page.find :table_row, 'tags'
    expect(tags_row).to have_css 'ul li', text: 'cool'
    expect(tags_row).to have_css 'ul li', text: 'night life'
  end
end
