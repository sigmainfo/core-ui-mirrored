class Spinach::Features::UserBrowsesAllTermsOfSourceAndTargetLanguage < Spinach::FeatureSteps
  include AuthSteps
  include LanguageSelectSteps
  include SearchSteps
  include Api::Graph::Factory

  def term_list
    find :xpath,
         '//h4[text()="Term List"]/ancestor::div[contains(@class, "widget")]'
  end

  def translations_for( term )
    within term_list do
      target = find( 'td.source a', text: /^#{term}$/ ).find( :xpath, '..' )
      source = target.find( :xpath, 'following-sibling::td[1]' )
      source.text.split /\s+|\s+/
    end
  end

  step 'a concept with English term "ball" exists' do
    @concept = create_concept terms: [ {lang: 'en', value: 'ball'} ]
  end

  step 'this concept has German terms "Ball", "Kugel"' do
    create_concept_term @concept, value: 'Ball', lang: 'de'
    create_concept_term @concept, value: 'Kugel', lang: 'de'
  end

  step 'a concept with English term "chalk" exists' do
    @concept = create_concept terms: [ {lang: 'en', value: 'chalk'} ]
  end

  step 'this concept has German term "Kreide"' do
    create_concept_term @concept, value: 'Kreide', lang: 'de'
  end

  step 'the following English terms exist: "vegetarian", "meal"' do
    %w(vegetarian meal).each do |term|
      create_concept terms: [ { lang: 'en', value: term } ]
    end
  end

  step 'the following German terms exist: "Asiatisches Essen", "Pilz"' do
    ['Asiatisches Essen', 'Pilz'].each do |term|
      create_concept terms: [ { lang: 'de', value: term } ]
    end
  end

  step 'I visit the repository root page' do
    visit "/#{@repository.id}"
  end


  step 'I should see a target language column inside the "Term List"' do
    within term_list do
      page.should have_css( 'table tr.term td.target' )
    end
  end

  step 'I should see "Ball", "Kugel" as translations for "ball"' do
    translations_for( 'ball' ).should include( 'Ball', 'Kugel' )
  end

  step 'I should see "Kreide" as translation for "chalk"' do
    pending 'step not implemented'
  end

  step 'I should see terms "vegetarian", "meal"' do
    pending 'step not implemented'
  end

  step 'they should not have a translation' do
    pending 'step not implemented'
  end

  step 'I should not see "Asiatisches Essen", "Pilz"' do
    pending 'step not implemented'
  end

  step 'I select "None" as target language' do
    pending 'step not implemented'
  end

  step 'I should not see a target language column anymore' do
    pending 'step not implemented'
  end

  step 'I select "German" as source language' do
    pending 'step not implemented'
  end

  step 'I select "English" as target language' do
    pending 'step not implemented'
  end

  step 'I should see "Ball", "Kugel" with translation "ball"' do
    pending 'step not implemented'
  end

  step 'I should see "Kreide" with translation "chalk"' do
    pending 'step not implemented'
  end

  step 'I should see terms "Asiatisches Essen", "Pilz"' do
    pending 'step not implemented'
  end

  step 'I should not see "vegetarian", "meal"' do
    pending 'step not implemented'
  end
end
