class Spinach::Features::UserBrowsesProperties < Spinach::FeatureSteps
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
    concepts["#{concept['id']}/properties"].post property: { key: 'label', value: 'Vampire' }
  end

  step 'that concept has a German term "Vampir"' do
    @term_attrs = { value: 'Vampir', lang: 'de' }
  end

  step 'that concept has a Greek term "βρυκόλακας"' do
    @term_attrs = { value: 'βρυκόλακας', lang: 'el' }
  end

  step 'a concept with term "vampire" exists' do
    @term_attrs = { value: 'vampire', lang: 'en' }
  end

  step 'that term has the property "status" set to "accepted"' do
    @term_attrs.merge! 'properties[]' => [{key: 'status', value: 'accepted'}]
    concepts["#{concept['id']}/terms"].post term: @term_attrs
  end

  step 'that concept has the property "dangerous" set to be true' do
    concepts["#{concept['id']}/properties"].post property: { key: 'dangerous', value: true }
  end

  step 'that concept has the property "alias" set to "Lamia"' do
    concepts["#{concept['id']}/properties"].post property: { key: 'alias', value: 'Lamia' }
  end

  step 'that concept has a property "definition"' do
    @property_attrs = { key: 'definition' }
  end

  step 'the English value is set to "corpse that drinks blood of the living"' do
    concepts["#{concept['id']}/properties"].post property: @property_attrs.merge({
      value: 'corpse that drinks blood of the living', lang: 'en'
    })
  end

  step 'the German value is set to "Untoter Blutsauger, mythische Gestalt"' do
    concepts["#{concept['id']}/properties"].post property: @property_attrs.merge({
      value: 'Untoter Blutsauger, mythische Gestalt', lang: 'de'
    })
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
    within :table_row, 'dangerous' do
      expect(page).to have_css("td .value", text: 'true')
    end
  end

  step 'I see a property "DEFINITION" that is empty' do
    within :table_row, 'definition' do
      expect(page).to have_css("td .value[data-empty]", visible: false)
    end
  end

  step 'I see a property "DEFINITION" with tabs "EN", "DE"' do
    within :table_row, 'definition' do
      %w(EN DE).each do |lang|
        expect(page).to have_css('td ul.index li', text: lang)
      end
    end
  end

  step 'I click on "EN" then I see "corpse that drinks blood of the living"' do
    within :table_row, 'definition' do
      page.find("li", text: 'EN').click
      expect(page).to have_content('corpse that drinks blood of the living')
    end
  end

  step 'I click on "DE" then I see "Untoter Blutsauger, mythische Gestalt"' do
    within :table_row, 'definition' do
      page.find("li", text: 'DE').click
      expect(page).to have_content('Untoter Blutsauger, mythische Gestalt')
    end
  end

  step 'I click on "TOGGLE ALL PROPERTIES"' do
    page.find('.terms *', text: 'Toggle all properties').click
  end

  step 'I see a property "ALIAS" with value "Lamia"' do
    within :table_row, 'alias' do
      expect(page).to have_css("td .value", text: 'Lamia')
    end
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

  step 'I should see the property "status" for both terms' do
    expect(page).to have_selector(:table_row, 'status', count: 2)
  end
end
