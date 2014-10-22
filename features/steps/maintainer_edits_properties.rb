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

  step 'I click "Create concept"' do
    click_button "Create concept"
  end

  step 'I see a listing "PROPERTIES" within the concept header' do
    expect(page).to have_css(".concept .properties")
  end

  step 'I see a property "SHORT DESCRIPTION" with English value "sucks blood; bat"' do
    within :table_row, 'short description' do
      expect(page).to have_css("td .value", text: 'sucks blood; bat')
    end
  end

  step 'I see a property "DANGEROUS" with value "no"' do
    within :table_row, 'dangerous' do
      expect(page).to have_css("td .value", text: 'no')
    end
  end
end
