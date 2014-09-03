class Spinach::Features::UserBrowsesProperties < Spinach::FeatureSteps
  include AuthSteps
  include Resources

  step 'the repository defines a blueprint for concept' do
    @blueprint = blueprint(:concept)
  end

  step 'that blueprint defines a property "dangerous" of type "boolean"' do
    @blueprint['properties'].post property: { key: 'dangerous', type: 'boolean' }
  end

  step 'that blueprint defines a property "definition" of type "text"' do
    @blueprint['properties'].post property: { key: 'definition', type: 'text' }
  end

  step 'a concept "Vampire" exists' do
    #concepts.post concept: { properties: { "" => [{ key: 'label', value: 'Vampire' }] } }
    @concept = JSON.parse concepts.post concept: { 'properties[]' => [{ key: 'label', value: 'Vampire' }] }
  end

  step 'that concept has the property "dangerous" set to be true' do
    concepts["#{@concept['id']}/properties"].post property: { key: 'dangerous', value: true }
  end

  step 'that concept has the property "alias" set to "Lamia"' do
    concepts["#{@concept['id']}/properties"].post property: { key: 'alias', value: 'Lamia' }
  end

  step 'I visit the concept details page for that concept' do
    visit "/#{current_repository.id}/concepts/#{@concept['id']}"
  end

  step 'I look at the properties inside the concept header' do
    page.should have_css(".concept .properties")
  end

  step 'I see a property "DANGEROUS" that is checked' do
    page.should have_css(".concept > .properties table tr.boolean[data-value=true]")
    page.should have_css(".concept > .properties table tr.boolean th", text: 'DANGEROUS')
  end

  step 'I see a property "DEFINITION" that is empty' do
    pending 'step not implemented'
  end

  step 'I see a property "ALIAS" with value "Lamia"' do
    pending 'step not implemented'
  end
end
