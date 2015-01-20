class Spinach::Features::UserBrowsesAssetProperties < Spinach::FeatureSteps
  include AuthSteps
  include Resources

  def concept
    @concept ||= JSON.parse concepts.post concept: {}
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

  step 'a concept "Crane" exists' do
    concepts["#{concept['id']}/properties"].post property: { key: 'label', value: 'Crane' }
  end

  step 'that concept has a property "image" with caption "front view"' do
    concepts["#{concept['id']}/properties"].post property: { key: 'image', value: { mime_type: 'image/jpeg', caption: 'front view', uri: '/assets/fron_view.jpeg', versions: { thumbnail_uri: '/assets/fron_view_thumb.jpeg' } } }
  end

  step 'that concept has a property "image" with caption "side view"' do
    concepts["#{concept['id']}/properties"].post property: { key: 'image', value: { mime_type: 'image/jpeg', caption: 'side view', uri: '/assets/side_view.jpeg' } }
  end

  step 'I visit the concept details page for that concept' do
    visit "/#{current_repository.id}/concepts/#{@concept['id']}"
  end

  step 'I look at the properties inside the concept header' do
    page.should have_css(".concept .properties")
  end

  step 'I see a property "IMAGE" that has two labels' do
    within :table_row, 'image' do
      %w(1 2).each do |lang|
        expect(page).to have_css('td ul.index li')
      end
    end
  end

  step 'I click on label "1"' do
    within :table_row, 'image' do
      @label = page.find("li", text: '1')
      expect(@label).to be_visible
    end
  end

  step 'I see a thumbnail captioned "front view"' do
    within :table_row, 'image' do
      image = page.find 'img'
      expect(page['src']).to eql '/assets/fron_view_thumb.jpeg'
    end
  end


end