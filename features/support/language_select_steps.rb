module LanguageSelectSteps
  include Spinach::DSL
  include Api::Graph::Factory

  def source_language_css
    '#coreon-languages .coreon-select[data-select-name=source_language]'
  end

  def source_language_select
    expect(page).to have_css(source_language_css)
    page.find source_language_css
  end

  def target_language_css
    '#coreon-languages .coreon-select[data-select-name=target_language]'
  end

  def target_language_select
    expect(page).to have_css(target_language_css)
    page.find target_language_css
  end

  def dropdown_css
    '#coreon-modal .coreon-select-dropdown'
  end

  def select_lang(key, lang)
    text =
      case lang.to_sym
      when :none then 'None'
      else lang.to_s.upcase
      end
    send("#{key}_language_select").click
    within dropdown_css do
      page.find('li', text: text).click
    end
  end

  def select_source_lang(lang)
    select_lang :source, lang
  end

  def select_target_lang(lang)
    select_lang :target, lang
  end

  step 'the languages "English", "German", and "French" are available' do
    current_repository.update_attributes languages: %w{en de fr}

    create_concept terms: [
      {lang: 'en', value: 'x'},
      {lang: 'de', value: 'x'},
      {lang: 'fr', value: 'x'}
    ]
  end

  step 'the languages "English", "German", "Russian", "Korean", and "French" are available' do
    current_repository.update_attributes languages: %w|en de ro ko fr|

    create_concept terms: [
      {lang: 'en', value: 'x'},
      {lang: 'de', value: 'x'},
      {lang: 'ru', value: 'x'},
      {lang: 'ko', value: 'x'},
      {lang: 'fr', value: 'x'}
    ]
  end

  step 'the repository provides the languages "English", "German", and "French"' do
    current_repository.update_attributes languages: %w{en de fr}

    create_concept terms: [
      {lang: 'en', value: 'English'},
      {lang: 'de', value: 'deutsch'},
      {lang: 'fr', value: 'français'}
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
    select_source_lang :en
  end

  step 'I select "German" as source language' do
    select_source_lang :de
  end

  step 'I select "French" as source language' do
    select_source_lang :fr
  end

  step 'I select "None" as source language' do
    select_source_lang :none
  end

  step 'I select "None" as target language' do
    select_target_lang :none
  end

  step 'I select "English" as target language' do
    select_target_lang :en
  end

  step 'I select "German" as target language' do
    select_target_lang :de
  end

  step 'I select "French" as target language' do
    select_target_lang :fr
  end

  step 'I select "None" as target language' do
    select_target_lang :none
  end
end
