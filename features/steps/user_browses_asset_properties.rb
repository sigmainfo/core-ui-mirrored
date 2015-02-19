class Spinach::Features::UserBrowsesAssetProperties < Spinach::FeatureSteps
  include AuthSteps
  include Resources

  def concept
    @concept ||= JSON.parse concepts.post concept: {}
  end

  def host_uri
    'http://localhost:3336/'
  end

  step 'the repository defines a blueprint for concept' do
    @blueprint = blueprint(:concept)
    @blueprint['clear'].delete
  end

  step 'the repository defines a blueprint for term' do
    @blueprint = blueprint(:term)
    @blueprint['clear'].delete
  end

  step 'that blueprint defines a property "image" of type "asset"' do
    @blueprint['properties'].post property: { key: 'image', type: 'asset', required: false, default: { mime_type: 'unknown' } }
  end

  step 'that blueprint defines a property "manual" of type "asset"' do
    @blueprint['properties'].post property: { key: 'manual', type: 'asset', required: false, default: { mime_type: 'unknown' } }
  end

  step 'a concept "Crane" exists' do
    concepts["#{concept['id']}/properties"].post property: { key: 'label', value: 'Crane' }
  end

  step 'a term "Crane" exists' do
    @term_attrs = { value: 'Crane', lang: 'en' }
  end

  step 'that concept has a property "image" with caption "Crane: front view"' do
    concepts["#{concept['id']}/properties"].post property: {
        key: 'image',
        value: 'Crane: front view',
        type: :asset,
        asset:  File.new(File.join(Rails.root, 'features', 'assets', 'front_view.jpg'), 'rb')
      }
  end

  step 'that concept has a property "image" with caption "Crane: side view"' do
    concepts["#{concept['id']}/properties"].post property: {
        key: 'image',
        value: 'Crane: side view',
        type: :asset,
        asset:  File.new(File.join(Rails.root, 'features', 'assets', 'side_view.jpg'), 'rb')
      }
  end

  step 'that concept has a property "image" with caption "Crane: front view" and language "EN"' do
    concepts["#{concept['id']}/properties"].post property: {
        key: 'image',
        value: 'Crane: front view',
        type: :asset,
        lang: 'en',
        asset:  File.new(File.join(Rails.root, 'features', 'assets', 'front_view.jpg'), 'rb')
      }
  end

  step 'that concept has a property "image" with caption "Kran: Vorderansicht" and language "DE"' do
    concepts["#{concept['id']}/properties"].post property: {
        key: 'image',
        value: 'Kran: Vorderansicht',
        type: :asset,
        lang: 'de',
        asset:  File.new(File.join(Rails.root, 'features', 'assets', 'side_view.jpg'), 'rb')
      }
  end

  step 'this term has a property "image" with caption "Crane: front view"' do
    @term_attrs.merge! 'properties[]' => [{
        key: 'image',
        value: 'Crane: front view',
        type: :asset,
        asset:  File.new(File.join(Rails.root, 'features', 'assets', 'front_view.jpg'), 'rb')
      }]
    @term_response = JSON.parse concepts["#{concept['id']}/terms"].post term: @term_attrs
  end

  step 'that concept has a property "manual" with caption "Tech manual"' do
    @concept_response = JSON.parse concepts["#{concept['id']}/properties"].post property: {
      key: 'manual',
      value: 'Tech manual',
      type: :asset,
      asset:  File.new(File.join(Rails.root, 'features', 'assets', 'manual.pdf'), 'rb')
    }
  end

  step 'I visit the concept details page for that concept' do
    visit "/#{current_repository.id}/concepts/#{@concept['id']}"
  end

  step 'I look at the properties inside the concept header' do
    page.should have_css(".concept .properties")
  end

  step 'I see a property "IMAGE"' do
    @image_property = page.find :table_row, 'image'
  end

  step 'I see a property "IMAGE" that has two thumbnails' do
    within :table_row, 'image' do
      images = page.all 'img', visible: false
      expect(images.size).to eq 2
    end
  end

  step 'I see a property "MANUAL" that has one thumbnail' do
    within :table_row, 'manual' do
      images = page.all 'img', visible: false
      expect(images.size).to eq 1
    end
  end

  step 'I see a property "IMAGE" with tabs "EN", "DE"' do
    within :table_row, 'image' do
      %w(EN DE).each do |lang|
        expect(page).to have_css('td ul.index li', text: lang)
      end
    end
  end

  step 'I click on "EN"' do
    within :table_row, 'image' do
      page.find("li", text: 'EN').click
    end
  end

  step 'I click on "DE"' do
    within :table_row, 'image' do
      page.find("li", text: 'DE').click
    end
  end

  step 'I see a thumbnail captioned "Crane: front view"' do
    within :table_row, 'image' do
      expect(page).to have_xpath '//figure/figcaption', text: 'Crane: front view'
    end
  end

  step 'I see a thumbnail captioned "Crane: side view"' do
    within :table_row, 'image' do
      expect(page).to have_xpath '//figure/figcaption', text: 'Crane: side view'
    end
  end

  step 'I see a thumbnail captioned "Kran: Vorderansicht"' do
    within :table_row, 'image' do
      expect(page).to have_xpath '//figure/figcaption', text: 'Kran: Vorderansicht'
    end
  end

  step 'I see a generic thumbnail captioned "Tech manual"' do
    within :table_row, 'manual' do
      expect(page).to have_xpath '//figure/img[@src="/assets/generic_asset.gif"]'
      expect(page).to have_xpath '//figure/figcaption', text: 'Tech manual'
    end
  end

  step 'there is a thumbnail captioned "front view"' do
    within @image_property do
      expect(page).to have_xpath '//figure/figcaption', text: 'Crane: front view'
    end
  end

  step 'I click on toggle "PROPERTIES" inside the term "Crane"' do
    @term = page.find(:term, 'Crane')
    @term.find('h3', text: 'PROPERTIES').click
  end

  step 'I click on the thumbnail' do
    within @image_property do
      page.find('img').click
    end
  end

  step 'I click on the generic thumbnail' do
    within :table_row, 'manual' do
      page.find('img').click
    end
  end

  step 'I see a large view of the asset' do
    within '#asset-view' do
      expect(page).to have_css "img[src=\"#{host_uri}#{@term_response['properties'][0]['value']['versions']['preview_uri']}\"]"
    end
  end

  step 'I see a download link' do
    within '#asset-view' do
      expect(page).to have_css ".download a[href=\"#{host_uri}#{@term_response['properties'][0]['value']['uri']}\"]"
    end
  end

  step 'I see a download link for the file' do
    expect(page).to have_css "a[href=\"#{host_uri}#{@concept_response['value']['uri']}\"]", visible: false
  end

end