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

  step 'the repository defines a blueprint for terms' do
    @blueprint = blueprint(:term)
    @blueprint['clear'].delete
  end

  step 'that blueprint requires a property "short description" of type "text"' do
    @blueprint['properties'].post property: {
      key: 'short description',
      type: 'text',
      required: true,
      default: ''
    }
  end

  step 'that blueprint requires a property "dangerous" of type "boolean"' do
    @property_attrs = {
      key: 'dangerous',
      type: 'boolean',
      required: true,
      default: false
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
    @property_attrs[:default] = ["cool", "night life"]
    @blueprint['properties'].post property: @property_attrs
  end

  step 'that blueprint allows a property "alias" of type "text"' do
    @blueprint['properties'].post property: {
      key: 'alias',
      type: 'text',
      required: false,
      default: ''
    }
  end

  step 'that blueprint allows a property "definition" of type "multiline text"' do
    @blueprint['properties'].post property: {
      key: 'definition',
      type: 'multiline_text',
      required: false,
      default: ''
    }
  end

  step 'that blueprint requires a property "author" of type "text"' do
    @blueprint['properties'].post property: {
      key: 'author',
      type: 'text',
      required: true,
      default: ''
    }
  end

  step 'that blueprint requires a property "source" of type "text"' do
    @blueprint['properties'].post property: {
      key: 'source',
      type: 'text',
      required: true,
      default: ''
    }
  end

  step 'that blueprint allows a property "status" of type "picklist"' do
    @property_attrs = {
      key: 'status',
      type: 'picklist',
      required: false
    }
  end

  step 'that property allows values: "pending", "accepted", "forbidden"' do
    @property_attrs[:values] = ["pending", "accepted", "forbidden"]
    @property_attrs[:default] = "pending"
    @blueprint['properties'].post property: @property_attrs
  end

  step 'that blueprint requires a property "quote" of type "multiline text"' do
    @blueprint['properties'].post property: {
      key: 'quote',
      type: 'multiline_text',
      required: true,
      default: ''
    }
  end

  step 'that blueprint does not require any properties' do
    @blueprint['clear'].delete
  end

  step 'a concept "Bloodbath" exists' do
    concepts["#{concept['id']}/properties"].post property: { key: 'label', value: 'Bloodbath' }
  end

  step 'a concept with English term "bloodbath" exists' do
    @term_attrs = { value: 'bloodbath', lang: 'en' }
  end

  step 'that concept has a property "status" with value "forbidden"' do
    concepts["#{concept['id']}/properties"].post property: { key: 'status', value: 'forbidden' }
  end

  step 'that term has a property "source" of "bloodbathproject.com"' do
    @term_attrs.merge! 'properties[]' => [{key: 'source', value: 'bloodbathproject.com'}]
    concepts["#{concept['id']}/terms"].post term: @term_attrs
  end

  step 'that concept has a property "quote" with value "That was visual."' do
    concepts["#{concept['id']}/properties"].post property: { key: 'quote', value: 'That was visual.' }
  end

  step 'that concept has a property "quote" with value "You drank Ian!"' do
    concepts["#{concept['id']}/properties"].post property: { key: 'quote', value: 'You drank Ian!' }
  end

  step 'that concept has a property "rating" with value "+++++"' do
    concepts["#{concept['id']}/properties"].post property: { key: 'rating', value: '+++++' }
  end

  step 'I click on "New concept"' do
    click_link "New concept"
  end

  step 'I edit that concept' do
    visit "/#{current_repository.id}/concepts/#{concept['id']}"
    click_link "Edit mode"
  end

  step 'I click "Add term"' do
    click_link "Add term"
  end

  step 'I click "Edit term" within the term "bloodbath"' do
    @term = page.find :term, 'bloodbath'
    within @term do
      click_link 'Edit term'
    end
  end

  step 'I see a section "PROPERTIES" within the form "Create concept"' do
    @form = page.find :form, 'Create concept'
    within @form do
      @section = page.find :section, 'Properties'
      expect(@section).to be_visible
    end
  end

  step 'I see a section "PROPERTIES" within the form "Create term"' do
    @form = page.find :form, 'Create term'
    within @form do
      @section = page.find :section, 'Properties'
      expect(@section).to be_visible
    end
  end

  step 'I see a section "PROPERTIES" within the form "Save term"' do
    @form = page.find :form, 'Save term'
    within @form do
      @section = page.find :section, 'Properties'
      expect(@section).to be_visible
    end
  end

  step 'I see a section "PROPERTIES"' do
    @section = page.find :section, 'Properties'
    expect(@section).to be_visible
  end

  step 'I see a deprecated property "RATING"' do
    within :section, 'Properties' do
      @fieldset = page.find :fieldset_with_title, "rating"
      expect(@fieldset).to be_visible
    end
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

  step 'I see a fieldset "SOURCE" within this section' do
    within @section do
      @fieldset = page.find :fieldset_with_title, "source"
      @source_fieldset = @fieldset
      expect(@fieldset).to be_visible
    end
  end

  step 'I see a fieldset "STATUS" within this form' do
    within @form do
      @fieldset = page.find :fieldset_with_title, "status"
      @status_fieldset = @fieldset
      expect(@fieldset).to be_visible
    end
  end

  step 'I see a fieldset "QUOTE" within this form' do
    within @form do
      @fieldset = page.find :fieldset_with_title, "quote"
      @status_fieldset = @fieldset
      expect(@fieldset).to be_visible
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

  step 'this fieldset contains a dropdown with selection "forbidden"' do
    within @fieldset do
      status_dropdown = find 'select'
      expect(status_dropdown[:value]).to eql 'forbidden'
    end
  end

  step 'I click on "Remove status" within "STATUS"' do
    within @fieldset do
      click_link "Remove status"
    end
  end

  step 'I see an input with "bloodbathproject.com"' do
    within @fieldset do
      input = page.find 'input[type=text]'
      expect(input[:value]).to eql 'bloodbathproject.com'
    end
  end

  step 'I see 2 text areas within "QUOTE"' do
    within @fieldset do
      @quote_textareas = page.all('textarea')
      expect(@quote_textareas.size).to eql 2
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

  step 'I click on "Add another source" inside "SOURCE"' do
    within @fieldset do
      click_link "Add another source"
    end
  end

  step 'I click on "Remove this rating" within "RATING"' do
    within @fieldset do
      click_link 'Remove this rating'
    end
  end

  step 'I click on "Delete value" for "You drank Ian!"' do
    within @fieldset do
      text_area = @quote_textareas.select{|t| t[:value] == "You drank Ian!"}.first
      remove_link = text_area.find(:xpath, './../../a[@class="remove-value"]')
      remove_link.click
    end
  end

  step 'I do not see a button "Delete value" for "That was visual."' do
    within @fieldset do
      text_area = @quote_textareas.select{|t| t[:value] == "That was visual."}.first
      remove_link = text_area.find(:xpath, './../../a[@class="remove-value"]', visible: false)
      expect(remove_link).to_not be_visible
    end
  end

  step 'I fill in the empty input with "wikipedia.org/wiki/Bloodbath"' do
    within @fieldset do
      inputs = page.all 'input[type=text]'
      input = inputs.select{|i| i[:value] == ''}.first
      fill_in input[:id], with: 'wikipedia.org/wiki/Bloodbath'
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

  step 'I fill in "Blutbad" for "VALUE"' do
    within @form do
      fill_in 'Value', with: 'Blutbad'
    end
  end

  step 'I fill in "de" for "LANGUAGE"' do
    within @form do
      fill_in 'Language', with: 'de'
    end
  end

  step 'the submit "Create term" is disabled' do
    within @form do
      submit = page.find :button, text: 'Create term', disabled: true
    end
  end

  step 'I fill in "Rüdiger von Schlotterstein" for "AUTHOR"' do
    within @form do
      @fieldset = page.find :fieldset_with_title, "author"
      @author_fieldset = @fieldset
      within @fieldset do
        fill_in page.find('input[type=text]')[:id], with: 'Rüdiger von Schlotterstein'
      end
    end
  end

  step 'the submit "Create term" is enabled' do
    within @form do
      submit = page.find :button, text: 'Create term'
      expect(submit).to be_visible
    end
  end

  step 'I click "Create concept"' do
    click_button "Create concept"
  end

  step 'I click "Save concept"' do
    click_button "Save concept"
  end

  step 'I click "Create term"' do
    click_button 'Create term'
  end

  step 'I click "Save term"' do
    click_button 'Save term'
  end

  step 'I see a confirmation dialog' do
    @popup = page.find 'div[id=coreon-modal]'
    expect(@popup).to be_visible
  end

  step 'I click "OK" on the confirmation dialog' do
    within @popup do
      ok_link = @popup.find "a", text: "OK"
      ok_link.click
    end
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

  step 'I see a property "QUOTE" with "That was visual."' do
    within :table_row, 'quote' do
      expect(page).to have_css "td .value", text: 'That was visual.', visible: false
    end
  end

  step 'I do not see "You drank Ian!"' do
    within :table_row, 'quote' do
      expect(page).to_not have_css "td .value", text: 'You drank Ian!', visible: false
    end
  end

  step 'I see term "Blutbad" within language section "DE"' do
    language_section = page.find :section, 'de'
    within language_section do
      @term = page.find :term, 'Blutbad'
      expect(@term).to be_visible
    end
  end

  step 'I see term "bloodbath" within language section "EN"' do
    language_section = page.find :section, 'en'
    within language_section do
      @term = page.find :term, 'bloodbath'
      expect(@term).to be_visible
    end
  end

  step 'I toggle "Properties" within this term' do
    within @term do
      properties_link = @term.find 'h3', text: 'Properties', visible: false
      properties_link.click
    end
  end

  step 'I see a property "AUTHOR" with value "Rüdiger von Schlotterstein"' do
    within @term do
      within :table_row, 'author' do
        expect(page).to have_css "td .value", text: 'Rüdiger von Schlotterstein'
      end
    end
  end

  step 'I see a property "SOURCE" with 2 values' do
    within @term do
      within :table_row, 'source' do
        values = page.all 'td .value', visible: false
        expect(values.size).to eql 2
      end
    end
  end

  step 'I do not see "STATUS" or "forbidden"' do
    expect(page).to_not have_selector :table_row, 'status'
    expect(page).to_not have_text 'forbidden'
  end

  step 'I do not see "RATING" or "+++++"' do
    expect(page).to_not have_selector :table_row, 'rating'
    expect(page).to_not have_text '+++++'
  end

  step 'I click "2"' do
    within @term do
      within :table_row, 'source' do
        second_tab = page.find 'ul.index li', text: '2'
        second_tab.click
      end
    end
  end

  step 'I see a link "wikipedia.org/wiki/Bloodbath"' do
    within @term do
      within :table_row, 'source' do
        link = page.find 'td .value', text: 'wikipedia.org/wiki/Bloodbath'
        expect(link).to be_visible
      end
    end
  end
end
