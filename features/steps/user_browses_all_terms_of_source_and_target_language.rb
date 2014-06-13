class Spinach::Features::UserBrowsesAllTermsOfSourceAndTargetLanguage < Spinach::FeatureSteps
  include AuthSteps
  include LanguageSelectSteps
  include SearchSteps
  include Api::Graph::Factory

  def term_list_title
    find( '.widget h3', text: 'Term List' )
  end

  def term_list
    term_list_title.find :xpath,
                         'ancestor::div[contains(@class, "widget")]'
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
    visit "/#{current_repository.id}"
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
    translations_for( 'chalk' ).should == [ 'Kreide' ]
  end

  step 'I should see terms "vegetarian", "meal"' do
    @terms = %w(vegetarian meal)
    within term_list do
      @terms.each do |term|
        page.should have_css( 'tr.term td.source', text: term )
      end
    end
  end

  step 'they should not have a translation' do
    @terms.each do |term|
      translations_for( term ).should be_empty
    end
  end

  step 'I should not see "Asiatisches Essen", "Pilz"' do
    within term_list do
      [ 'Asiatisches Essen', 'Pilz' ].each do |term|
        page.should have_no_css( 'tr.term td.source', text: term )
      end
    end
  end

  step 'I should not see a target language column anymore' do
    within term_list do
      page.should have_no_css( 'td.target' )
    end
  end

  step 'I should see "Ball", "Kugel" with translation "ball"' do
    %w(Ball Kugel).each do |term|
      translations_for( term ).should == [ 'ball' ]
    end
  end

  step 'I should see "Kreide" with translation "chalk"' do
    translations_for( 'Kreide' ).should == [ 'chalk' ]
  end

  step 'I should see terms "Asiatisches Essen", "Pilz"' do
    @terms = [ 'Asiatisches Essen', 'Pilz' ]
    within term_list do
      @terms.each do |term|
        page.should have_css( 'tr.term td.source', text: term )
      end
    end
  end

  step 'I should not see "vegetarian", "meal"' do
    within term_list do
      %w(vegetarian meal).each do |term|
        page.should have_no_css( 'tr.term td.source', text: term )
      end
    end
  end

  step 'I should see "Term List (EN, DE)" inside the widget title' do
    term_list_title.should have_text( 'Term List (EN, DE)' )
  end

  step 'I should see "Term List (EN)" inside the widget title' do
    term_list_title.should have_text( 'Term List (EN)' )
  end

  step 'I should see "Term List" only inside the widget title' do
    term_list_title.should have_text( /^Term List$/ )
  end
end
