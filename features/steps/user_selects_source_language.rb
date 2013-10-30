class Spinach::Features::UserSelectsSourceLanguage < Spinach::FeatureSteps

  include AuthSteps
  
  def source_language_css
    "#coreon-languages .coreon-select[data-select-name=source_language]"
  end
  
  def dropdown_css
    "#coreon-modal .coreon-select-dropdown"
  end

  step 'the languages "English", "German", and "French" are available' do
    @repository.update_attributes languages: %w{en de fr}
  end

  step 'I visit the repository root page' do
    visit "/#{@repository.id}"
  end

  step 'I should see a widget "Languages"' do
    page.should have_css ".widget h4", text: "Languages"
  end

  step 'I should see selection "None" for "Source language"' do
    page.should have_css source_language_css, text: "None"
  end

  step 'I click the "Source Language" selector' do
    page.find(source_language_css).click
  end

  step 'I should see a dropdown with "None", "English", "German", and "French"' do
    within dropdown_css do
      page.should have_css "li", text: "None"
      page.should have_css "li", text: "English"
      page.should have_css "li", text: "German"
      page.should have_css "li", text: "French"
    end
  end

  step 'I select "German" from the dropdown' do
    within dropdown_css do
      page.find("li", text: "German").click
    end
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
