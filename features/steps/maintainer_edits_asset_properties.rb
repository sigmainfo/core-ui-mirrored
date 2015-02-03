class Spinach::Features::MaintainerEditsAssetProperties < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include Resources
  include Selectors

  def concept
    @concept ||= JSON.parse concepts.post concept: {}
  end

  step 'the repository defines a blueprint for concept' do
    @blueprint = blueprint(:concept)
    @blueprint['clear'].delete
  end

  step 'that blueprint defines a property "image" of type "asset"' do
    @blueprint['properties'].post property: { key: 'image', type: 'asset', required: true, default: { mime_type: 'unknown' } }
  end

  step 'I click on "New concept"' do
    click_link "New concept"
  end

  step 'I see a section "PROPERTIES" within the form "Create concept"' do
    @form = page.find :form, 'Create concept'
    within @form do
      @section = page.find :section, 'Properties'
      expect(@section).to be_visible
    end
  end

  step 'I see a fieldset "IMAGE" within this section' do
    within @section do
      @fieldset = page.find :fieldset_with_title, "image"
      @short_descr_fieldset = @fieldset
      expect(@fieldset).to be_visible
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

end
