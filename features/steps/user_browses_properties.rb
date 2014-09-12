class Spinach::Features::UserBrowsesProperties < Spinach::FeatureSteps
  include AuthSteps
  include Resources

  step 'the repository defines a blueprint for concept' do
    @blueprint = blueprint(:concept)
    @blueprint['clear'].delete
  end

  step 'the repository defines a blueprint for term' do
    @blueprint = blueprint(:term)
    @blueprint['clear'].delete
  end

  step 'that blueprint defines a property "dangerous" of type "boolean"' do
    @blueprint['properties'].post property: { key: 'dangerous', type: 'boolean' }
  end

  step 'that blueprint defines a property "definition" of type "text"' do
    @blueprint['properties'].post property: { key: 'definition', type: 'text' }
  end

  step 'that blueprint defines a property "status" of type "picklist"' do
    @property_attrs = { key: 'status', type: 'picklist' }
  end

  step 'that property allows values: "accepted", "forbidden", "deprecated"' do
    @property_attrs.merge! values: ["accepted", "forbidden", "deprecated"]
    @blueprint['properties'].post property: @property_attrs
  end

  step 'a concept "Vampire" exists' do
    response = concepts.post concept: { 'properties[]' => [{ key: 'label', value: 'Vampire' }] }
    @concept = JSON.parse response
  end

  step 'a concept with term "vampire" exists' do
    @term_attrs = { value: 'vampire', lang: 'en' }
  end

  step 'that term has the property "status" set to "accepted"' do
    @term_attrs.merge! 'properties[]' => [{key: 'status', value: 'accepted'}]
    response = concepts.post concept: { 'terms[]' => [@term_attrs] }
    @concept = JSON.parse response
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

  step 'I click on toggle "PROPERTIES" inside the term "vampire"' do
    @term = page.find(:term, 'vampire')
    @term.find('h3', text: 'PROPERTIES').click
  end

  step 'I look at the properties inside the concept header' do
    page.should have_css(".concept .properties")
  end

  step 'I see a property "DANGEROUS" that is checked' do
    th = find(".concept > .properties table tr.boolean th", text: 'DANGEROUS')
    tr = th.find(:xpath, "..")
    tr.should have_css("td .value", text: 'true')
  end

  step 'I see a property "DEFINITION" that is empty' do
    th = find(".concept > .properties table tr.text th", text: 'DEFINITION')
    tr = th.find(:xpath, "..")
    tr.should have_css("td .value[data-empty]", visible: false)
  end

  step 'I see a property "ALIAS" with value "Lamia"' do
    th = find(".concept > .properties table tr th", text: 'ALIAS')
    tr = th.find(:xpath, "..")
    tr.should have_css("td .value", text: 'Lamia')
  end

  step 'I see a listing of properties inside that term' do
    @term_properties = @term.find('.properties table')
    expect(@term_properties).to be_visible
  end

  step 'this listing contains a picklist "STATUS" with value "accepted"' do
    within @term_properties do
      expect(page).to have_css('tr .value .picklist-item', text: 'accepted')
    end
  end
end
