module LanguageSelectSteps
  include Spinach::DSL
  include Api::Graph::Factory

  def source_language_css
    "#coreon-languages .coreon-select[data-select-name=source_language]"
  end

  def target_language_css
    "#coreon-languages .coreon-select[data-select-name=target_language]"
  end

  def dropdown_css
    "#coreon-modal .coreon-select-dropdown"
  end

  step 'the languages "English", "German", and "French" are available' do
    @repository.update_attributes languages: %w{en de fr}

    create_concept terms: [
      {lang: 'en', value: 'x'},
      {lang: 'de', value: 'x'},
      {lang: 'fr', value: 'x'}
    ]
  end

  step 'I click the "Source Language" selector' do
    page.find(source_language_css).click
  end

  step 'I click the "Target Language" selector' do
    page.find(target_language_css).click
  end

  step 'I select "None" from the dropdown' do
    within dropdown_css do
      page.find("li", text: "None").click
    end
  end

  step 'I select "English" from the dropdown' do
    within dropdown_css do
      page.find("li", text: "English").click
    end
  end

  step 'I select "German" from the dropdown' do
    within dropdown_css do
      page.find("li", text: "German").click
    end
  end

  step 'I select "Korean" from the dropdown' do
    within dropdown_css do
      page.find("li", text: "Korean").click
    end
  end

  step 'I select "French" from the dropdown' do
    within dropdown_css do
      page.find("li", text: "French").click
    end
  end

  step 'I select "English" as source language' do
    page.find(source_language_css).click
    within dropdown_css do
      page.find("li", text: "English").click
    end
  end

  step 'I select "German" as source language' do
    page.find(source_language_css).click
    within dropdown_css do
      page.find("li", text: "German").click
    end
  end
end
