class Spinach::Features::MaintainerEditsAssetProperties < Spinach::FeatureSteps
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

  step 'that blueprint defines a required property "image" of type "asset"' do
    @blueprint['properties'].post property: { key: 'image', type: 'asset', required: true, default: { mime_type: 'unknown' } }
  end

  step 'that blueprint defines a property "image" of type "asset"' do
    @blueprint['properties'].post property: { key: 'image', type: 'asset', required: false, default: { mime_type: 'unknown' } }
  end

  step 'that blueprint defines a property "description" of type "text"' do
    @blueprint['properties'].post property: { key: 'description', type: 'text', required: true, default: '' }
  end

  step 'that blueprint defines a required property "manual" of type "asset"' do
    @blueprint['properties'].post property: { key: 'manual', type: 'asset', required: true, default: { mime_type: 'unknown' } }
  end

  step 'a concept "Crane" exists' do
    concepts["#{concept['id']}/properties"].post property: { key: 'label', value: 'Crane', type: :text }
  end

  step 'a concept with the english term "Crane" exists' do
    @term_attrs = { value: 'Crane', lang: 'en' }
  end

  step 'that term has a property "image" with caption "Crane photo"' do
    @term_attrs.merge! 'properties[]' => [{
      key: 'image',
      value: 'Crane photo',
      type: :asset,
      asset:  File.new(File.join(Rails.root, 'features', 'assets', 'LTM1750.jpg'), 'rb')
    }]
    @term = JSON.parse concepts["#{concept['id']}/terms"].post term: @term_attrs
  end

  step 'that term has a property "description" with caption "Crane"' do
    concepts["#{concept['id']}/terms/#{@term['id']}/properties"].post property: {
        key: 'description',
        value: 'Crane',
        type: :text
      }
  end

  step 'that concept has a property "image" with caption "Crane photo"' do
    concepts["#{concept['id']}/properties"].post property: {
        key: 'image',
        value: 'Crane photo',
        type: :asset,
        asset:  File.new(File.join(Rails.root, 'features', 'assets', 'LTM1750.jpg'), 'rb')
      }
  end

  step 'I click on "New concept"' do
    click_link "New concept"
  end

  step 'I click "Add term"' do
    click_link "Add term"
  end

  step 'I click "Remove term"' do
    click_link "Remove term"
  end

  step 'I click "Edit term" within the term "Crane"' do
    @term = page.find :term, 'Crane'
    within @term do
      click_link 'Edit term'
    end
  end

  step 'I see a section "PROPERTIES" within the form "Save term"' do
    @form = page.find :form, 'Save term'
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

  step 'I edit that concept' do
    visit "/#{current_repository.id}/concepts/#{concept['id']}"
    click_link "Edit mode"
  end

  step 'I click on "Edit properties"' do
    click_link "Edit properties"
  end

  step 'I see a form "Save concept"' do
    @form = page.find :form, 'Save concept'
    expect(@form).to be_visible
  end

  step 'I see a section "PROPERTIES"' do
    @section = page.find :section, 'Properties'
    expect(@section).to be_visible
  end

  step 'I see a section "PROPERTIES" within the form "Create concept"' do
    @form = page.find :form, 'Create concept'
    within @form do
      @section = page.find :section, 'Properties'
      expect(@section).to be_visible
    end
  end

  step 'I see a section "PROPERTIES" under "TERMS" within the form "Create concept"' do
    @form = page.find :form, 'Create concept'
    within @form do
      within '.terms' do
        @section = page.find :section, 'Properties'
        expect(@section).to be_visible
      end
    end
  end

  step 'I see a section "PROPERTIES" under "TERMS" within the form "Create term"' do
    @form = page.find :form, 'Create term'
    within @form do
      @section = page.find :section, 'Properties'
      expect(@section).to be_visible
    end
  end


  step 'I see a fieldset "IMAGE" within this section' do
    within @section do
      @fieldset = page.find :fieldset_with_title, "image"
      @image_fieldset = @fieldset
      expect(@fieldset).to be_visible
    end
  end

  step 'this fieldset contains a text input titled "CAPTION"' do
    within @fieldset do
      @caption_field = find_field 'Caption'
      expect(@caption_field).to be_visible
    end
  end

  step 'this fieldset contains a file input' do
    within @fieldset do
      expect(page).to have_selector 'input[type=file]'
    end
  end

  step 'this fieldset contains a select "LANGUAGE"' do
    within @fieldset do
      expect(page).to have_selector '.input.lang .coreon-select'
    end
  end

  step 'I see a fieldset "IMAGE" within this form' do
    within @form do
      @fieldset = page.find :fieldset_with_title, "image"
      @image_fieldset = @fieldset
      expect(@fieldset).to be_visible
    end
  end

  step 'I see a fieldset "MANUAL" within this section' do
    within @form do
      @fieldset = page.find :fieldset_with_title, "manual"
      @manual_fieldset = @fieldset
      expect(@fieldset).to be_visible
    end
  end

  step 'this fieldset contains an image captioned "Crane photo"' do
    within @fieldset do
      expect(page).to have_xpath '//figure/img'
      expect(page).to have_xpath '//figure/figcaption', text: 'Crane photo'
    end
  end

  step 'I fill in "Crane" for "VALUE"' do
    within @form do
      fill_in 'Value', with: 'Crane'
    end
  end

  step 'I fill in "en" for "LANGUAGE"' do
    fieldset = page.find '.terms .term > .lang'
    select_from_coreon_dropdown fieldset, 'English'
  end

  step 'I fill in "CAPTION" with "Crane photo"' do
    within @fieldset do
      fill_in 'Caption', with: 'Crane photo'
    end
  end

  step 'I fill in "CAPTION" with "Front view"' do
    within @fieldset do
      fill_in 'Caption', with: 'Front view'
    end
  end

  step 'I fill in "CAPTION" with "Tech manual"' do
    within @fieldset do
      fill_in 'Caption', with: 'Tech manual'
    end
  end

  step 'I select file "LTM1750.jpg" for the file input' do
    within @image_fieldset do
      attach_file page.find('input[type=file]')[:id], File.join(Rails.root, 'features', 'assets', 'LTM1750.jpg')
    end
  end

  step 'I select file "front_view.jpg" for the file input' do
    within @fieldset do
      attach_file page.find('input[type=file]')[:id], File.join(Rails.root, 'features', 'assets', 'front_view.jpg')
    end
  end

  step 'I select file "manual.pdf" for the file input' do
    within @fieldset do
      attach_file page.find('input[type=file]')[:id], File.join(Rails.root, 'features', 'assets', 'manual.pdf')
    end
  end

  step 'I click on "Add another image" inside "IMAGE"' do
    within @fieldset do
      click_link "Add another image"
    end
  end

  step 'I see a preview thumbnail of the image' do
    within @image_fieldset do
      thumbnail = page.find '.asset-preview img'
      expect(thumbnail).to be_visible
    end
  end

  step 'I see a generic thumbnail' do
    within @manual_fieldset do
      thumbnail = page.find :xpath, '//div[@class="asset-preview"]/figure/img[@src="/assets/generic_asset.png"]'
      expect(thumbnail).to be_visible
    end
  end

  step 'I select "English" for "LANGUAGE"' do
    select_from_coreon_dropdown @fieldset, 'English'
  end

  step 'I click on "Remove image" within "IMAGE"' do
    within @fieldset do
      click_link "Remove this image"
    end
  end

  step 'I click "Create concept"' do
    click_button "Create concept"
  end

  step 'I click "Save concept"' do
    click_button "Save concept"
  end

  step 'I click "Save term"' do
    click_button 'Save term'
  end

  step 'I click "Create term"' do
    click_button 'Create term'
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

  step 'I see term "Crane" within language section "EN"' do
    language_section = page.find :section, 'en'
    within language_section do
      @term = page.find :term, 'Crane'
      expect(@term).to be_visible
    end
  end

  step 'I toggle "Properties" within this term' do
    within @term do
      properties_link = @term.find 'h3', text: 'Properties', visible: false
      properties_link.click
    end
  end

  step 'I look at the properties inside the concept header' do
    page.should have_css(".concept .properties")
  end


  step 'I visit the concept details page for that concept' do
    visit "/#{current_repository.id}/concepts/#{@concept['id']}"
  end

  step 'I see a property "IMAGE"' do
    @image_property = page.find :table_row, 'image'
  end

  step 'I see a property "MANUAL"' do
    @image_property = page.find :table_row, 'manual'
  end

  step 'there is a thumbnail captioned "Crane photo"' do
    within :table_row, 'image' do
      expect(page).to have_xpath '//figure/figcaption', text: 'Crane photo'
    end
  end

  step 'there is a thumbnail captioned "Front view"' do
    within :table_row, 'image' do
      expect(page).to have_xpath '//figure/figcaption', text: 'Front view'
    end
  end

  step 'there is a thumbnail captioned "Tech manual"' do
    within :table_row, 'manual' do
      expect(page).to have_xpath '//figure/figcaption', text: 'Tech manual'
    end
  end

  step 'I do not see "IMAGE"' do
    expect(page).to_not have_selector :table_row, 'image'
  end
end
