class Spinach::Features::UserSelectsSourceLanguage < Spinach::FeatureSteps

  include AuthSteps

  step 'the languages "English", "German", and "French" are available' do
    @repository.update_attributes languages: %w{en de fr}
  end

  step 'I visit the repository root page' do
    visit "/#{@repository.id}"
  end

  step 'I should see a widget "Languages"' do
    pending 'step not implemented'
  end

  step 'I should see selection "None" for "Source language"' do
    pending 'step not implemented'
  end

  step 'I click the trigger next to "Source Language"' do
    pending 'step not implemented'
  end

  step 'I should see a dropdown with "None", "English", "German", and "French"' do
    pending 'step not implemented'
  end

  step 'I select "German" from the dropdown' do
    pending 'step not implemented'
  end

  step 'I should see selection "German" for "Source language"' do
    pending 'step not implemented'
  end

  step 'I should not see a dropdown' do
    pending 'step not implemented'
  end

  step 'I reload the page' do
    pending 'step not implemented'
  end
end
