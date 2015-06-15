class Spinach::Features::UserBrowsesAllTermsOfSourceLanguage < Spinach::FeatureSteps
  include AuthSteps
  include LanguageSelectSteps
  include SearchSteps
  include Factory

  step 'a concept with English term "ball" exists' do
    @concept = create_concept terms: [ {lang: 'en', value: 'ball'} ]
  end

  step 'this concept has German terms "Ball", "Kugel"' do
    create_concept_term @concept, value: 'Ball', lang: 'de'
    create_concept_term @concept, value: 'Kugel', lang: 'de'
  end

  step 'the following English terms exist: "chalk", "cue", "billiards"' do
    %w(chalk cue billiards).each do |term|
      create_concept terms: [ { lang: 'en', value: term } ]
    end
  end

  step 'the following English terms exist: "vegetarian meal", "mushroom"' do
    ['vegetarian meal', 'mushroom'].each do |term|
      create_concept terms: [ { lang: 'en', value: term } ]
    end
  end

  step 'the following German terms exist: "Kreide", "Queue", "Billiard"' do
    %w(Kreide Queue Billiard).each do |term|
      create_concept terms: [ { lang: 'de', value: term } ]
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

  step 'I should see "ball", "billiards", "chalk", "cue" inside the Term List' do
    within '#coreon-term-list' do
      %w(ball billiards chalk cue).each_with_index do |term, i|
        page.should have_css("tbody tr:nth-child(#{ i + 1 }) td.source", text: term)
      end
    end
  end

  step 'and these should be followed by "mushroom", "vegetarian meal"' do
    within '#coreon-term-list' do
     ['mushroom', 'vegetarian meal'].each_with_index do |term, i|
        page.should have_css("tbody tr:nth-child(#{ i + 5 }) td.source", text: term)
      end
    end
  end

  step 'I should see "Asiatisches Essen", "Ball" inside the Term List' do
    within '#coreon-term-list' do
     ['Asiatisches Essen', 'Ball'].each_with_index do |term, i|
        page.should have_css("tbody tr:nth-child(#{ i + 1 }) td.source", text: term)
      end
    end
  end

  step 'and these should be followed by "Billiard", "Kreide", "Kugel", "Pilz"' do
    within '#coreon-term-list' do
      %w(Billiard Kreide Kugel Pilz).each_with_index do |term, i|
        page.should have_css("tbody tr:nth-child(#{ i + 3 }) td.source", text: term)
      end
    end
  end

  step 'and these should be followed by "Queue"' do
    within '#coreon-term-list' do
      page.should have_css( "tbody tr:nth-child(7) td.source", text: 'Queue' )
    end
  end

  step 'I click on "Ball"' do
    within '#coreon-term-list' do
      page.find( "tbody tr.term td.source a", text: 'Ball' ).click
    end
  end

  step 'I should see "Ball", "Kugel" inside the Term List' do
    within '#coreon-term-list' do
      %w(Ball Kugel).each_with_index do |term, i|
        page.should have_css( "tbody tr:nth-child( #{ i + 1 } ) td.source", text: term , visible: false)
      end
    end
  end

  step 'I click on "Toggle scope"' do
    within '#coreon-term-list' do
      click_on 'Toggle scope'
    end
  end

  step '"Ball", "Kugel" should be marked as being currently selected' do
    within '#coreon-term-list' do
      %w(Ball Kugel).each do |term|
        tr = page.find( "tbody tr.term", text: term )
        tr[:class].split( ' ' ).should include( 'hit' )
      end
    end
  end
end
