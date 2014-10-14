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

  step 'that property defines labels "yes" and "no"' do
    @property_attrs[:labels] = ["yes", "no"]
    @blueprint['properties'].post property: @property_attrs
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

  step 'I see a fieldset "SHORT DESCRIPTION" within this section' do
    within @section do
      binding.pry
      @fieldset_short_descr = page.find :fieldset_with_name, "SHORT DESCRIPTION"
      expect(@fieldset_short_descr).to be_visible
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
      select 'en', from: 'Language'
    end
  end

  step 'I uncheck "VALUE" for "dangerous"' do
    within @fieldset_dangerous do
      uncheck 'Value'
    end
  end

  step 'I click "Create concept"' do
    click_button "Create concept"
  end

  step 'I see a listing "PROPERTIES" within the concept header' do
    expect(page).to have_css(".concept .properties")
  end

  step 'I see a property "DEFINITION" with English value "sucks blood; bat"' do
    within :table_row, 'definition' do
      expect(page).to have_css("td .value", text: 'sucks blood; bat')
    end
  end

  step 'I see a property "DANGEROUS" that is unchecked' do
    within :table_row, 'dangerous' do
      expect(page).to have_css("td .value", text: 'false')
    end
  end
end
