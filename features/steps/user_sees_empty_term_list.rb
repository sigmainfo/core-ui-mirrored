class Spinach::Features::UserSeesEmptyTermList < Spinach::FeatureSteps
  include AuthSteps
  include LanguageSelectSteps

  step 'I visit the repository root' do
    visit "/#{current_repository.id}"
  end

  step 'I should see a widget "Term List"' do
    page.should have_css('.widget .titlebar h3', text: 'Term List')
  end

  step 'this widget should contain "No language selected"' do
    widget = page.find('.widget .titlebar h3', text: 'Term List').find(:xpath, '../..')
    widget.should have_text('No language selected')
  end
end
