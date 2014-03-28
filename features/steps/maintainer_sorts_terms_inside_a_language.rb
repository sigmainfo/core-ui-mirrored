class Spinach::Features::MaintainerSortsTermsInsideALanguage < Spinach::FeatureSteps

  include AuthSteps
  include Api::Graph::Factory

  step 'a concept with English terms "pistol", "handgun", and "revolver"' do
    @concept  = create_concept
    @pistol   = create_concept_term @concept, lang: 'en', value: 'pistol'
    @handgun  = create_concept_term @concept, lang: 'en', value: 'handgun'
    @revolver = create_concept_term @concept, lang: 'en', value: 'revolver'
  end

  step '"revolver" has a precedence of 1' do
    update_concept_term @concept, @revolver, precedence: 1
  end

  step '"pistol" has a precedence of 2' do
    update_concept_term @concept, @pistol, precedence: 2
  end

  step '"handgun" has a precedence of 3' do
    update_concept_term @concept, @handgun, precedence: 3
  end

  step 'I visit the concept details page' do
    visit "/#{@repository.id}/concepts/#{@concept['id']}"
  end

  step 'I see 3 terms inside language "EN"' do
    binding.pry
  end

  step 'they have the following order: "revolver", "pistol", "handgun"' do
    pending 'step not implemented'
  end

  step 'I toggle "EDIT MODE"' do
    pending 'step not implemented'
  end

  step 'I see a drag handler inside each term' do
    pending 'step not implemented'
  end

  step 'I drag "handgun" to the top of the list' do
    pending 'step not implemented'
  end

  step 'the order of the terms has changed to "handgun", "revolver", "pistol"' do
    pending 'step not implemented'
  end

  step 'I reload the concept details page' do
    pending 'step not implemented'
  end

  step 'the order of the terms is still "handgun", "revolver", "pistol"' do
    pending 'step not implemented'
  end
end
