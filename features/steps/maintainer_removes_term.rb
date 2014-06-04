class Spinach::Features::MaintainerRemovesTerm < Spinach::FeatureSteps

  include AuthSteps
  include Api::Graph::Factory
  include Editing
  include Selectors

  step 'a concept with an English term "beaver hat" exists' do
    @concept = create_concept terms: [ {lang: 'en', value: 'beaver hat'} ]
  end

  step 'I edit this concept' do
    edit_concept_details @concept
  end

  step 'I see a term "beaver hat"' do
    expect(page).to have_selector(:term, 'beaver hat')
  end
end
