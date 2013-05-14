class Spinach::Features::MaintainerDeletesConcept < Spinach::FeatureSteps

  include AuthSteps
  include EditSteps
  include Api::Graph::Factory

  step 'a concept with an English term "beaver hat" exists' do
    @concept = create_concept terms: [
      { lang: "en", value: "beaver hat" }
    ]
  end

  step 'I am on the show concept page of this concept' do
    page.execute_script "Backbone.history.navigate('concepts/#{@concept['_id']}', { trigger: true })"
  end

  step 'I click "Delete concept"' do
    click_link "Delete concept"
  end

  step 'I should see a confirmation dialog "This concept including all terms will be deleted permanently."' do
    pending 'step not implemented'
  end

  step 'I click outside the dialog' do
    pending 'step not implemented'
  end

  step 'I should not see a confirmation dialog' do
    pending 'step not implemented'
  end

  step 'I should still be on the show concept page' do
    pending 'step not implemented'
  end

  step 'I click "OK" within the dialog' do
    pending 'step not implemented'
  end

  step 'I should be on the repository root page' do
    pending 'step not implemented'
  end

  step 'I should see a message \'Successfully deleted concept "beaver hat".\'' do
    pending 'step not implemented'
  end

  step 'I search for "hat"' do
    pending 'step not implemented'
  end

  step 'I should not see "beaver hat"' do
    pending 'step not implemented'
  end
end
