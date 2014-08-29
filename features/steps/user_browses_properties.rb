class Spinach::Features::UserBrowsesProperties < Spinach::FeatureSteps
  include AuthSteps
  include Resources

  step 'the repository defines a blueprint for concept' do
    @blueprint = blueprint(:concept)
  end

  step 'that blueprint defines a property "dangerous" of type "boolean"' do
    @blueprint['properties'].post properties: {
      key: 'dangerous',
      type: 'boolean',
    }
  end

  step 'that blueprint defines a property "definition" of type "text"' do
    pending 'step not implemented'
  end

  step 'a concept "Vampire" exists' do
    pending 'step not implemented'
  end

  step 'that concept has the property "dangerous" set to be true' do
    pending 'step not implemented'
  end

  step 'that concept has the property "alias" set to "Lamia"' do
    pending 'step not implemented'
  end

  step 'I visit the concept details page for that concept' do
    pending 'step not implemented'
  end

  step 'I look at the properties inside the concept header' do
    pending 'step not implemented'
  end

  step 'I see a property "DANGEROUS" that is checked' do
    pending 'step not implemented'
  end

  step 'I see a property "DEFINITION" that is empty' do
    pending 'step not implemented'
  end

  step 'I see a property "ALIAS" with value "Lamia"' do
    pending 'step not implemented'
  end
end
