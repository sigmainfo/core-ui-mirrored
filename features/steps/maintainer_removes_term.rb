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
    confirm_edit
  end

  step 'I do not see the confirmation dialog anymore' do
    expect(page).to have_no_selector(:confirmation_dialog)
  end

  step 'I do not see the term "beaver hat" anymore' do
    expect(page).to have_no_selector(:term, 'beaver habeaver hatt')
  end

  step 'I see a message \'Successfully deleted term "beaver hat"\'' do
    expect(page).to have_selector(:notification,
                                  'Successfully deleted term "beaver hat"')
  end

  step 'I click to cancel' do
    cancel_edit
  end

  step 'I still see the term "beaver hat"' do
    within concept_details do
      expect(page).to have_selector(:term, 'beaver hat')
    end
  end
end
