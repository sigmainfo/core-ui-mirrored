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
    within concept_details do
      expect(page).to have_selector(:term, 'beaver hat')
      @term = find(:term, 'beaver hat')
    end
  end

  step 'I click "Remove term" inside of it' do
    within @term do
      click_link 'Remove term'
    end
  end

  step 'I see a confirmation dialog' do
    expect(page).to have_selector(:confirmation_dialog)
  end

  step 'I click to confirm' do
    within :confirmation_dialog do
      click_link 'OK'
    end
  end
end
