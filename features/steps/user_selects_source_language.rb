class Spinach::Features::UserSelectsSourceLanguage < Spinach::FeatureSteps

  include AuthSteps
  include LanguageSelectSteps

  step 'I visit the repository root page' do
    visit "/#{@repository.id}"
  end

  step 'I should see a widget "Languages"' do
    page.should have_css ".widget h4", text: "Languages"
  end

  step 'I should see a dropdown with "None", "English", "German", and "French"' do
    within dropdown_css do
      page.should have_css "li", text: "None"
      page.should have_css "li", text: "English"
      page.should have_css "li", text: "German"
      page.should have_css "li", text: "French"
    end
  end

  step 'I should see selection "None" for "Source language"' do
    page.should have_css source_language_css, text: "None"
  end

  step 'I should see selection "German" for "Source language"' do
    page.should have_css source_language_css, text: "German"
  end

  step 'I should not see a dropdown' do
    page.should have_no_css dropdown_css
  end

  step 'I reload the page' do
    visit(current_path)
  end
end
