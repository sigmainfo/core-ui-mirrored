class Spinach::Features::UserBrowsesAllTermsOfSourceLanguage < Spinach::FeatureSteps
  include AuthSteps
  include LanguageSelectSteps
  include SearchSteps
  include Api::Graph::Factory

  step 'concept with English term "ball" exists' do
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
    visit "/#{@repository.id}"
  end

  step 'I should see "ball", "billiards", "chalk", "cue" inside the Term List' do
    within '#coreon-term-list' do
      %w(ball billiards chalk cue).each_with_index do |term, i|
        page.should have_css("tbody tr:nth-child(#{ i + 1 }) td.source", text: term)
      end
    end
  end

  step 'and these should be followed by "mushroom", "vegetarian meal"' do
    pending 'step not implemented'
  end

  step 'I should see "Asiatisches Essen", "Ball" inside the Term List' do
    pending 'step not implemented'
  end

  step 'and these should be followed by "Billiard", "Kreide", "Kugel", "Pilz"' do
    pending 'step not implemented'
  end

  step 'and these should be followed by "Queue"' do
    pending 'step not implemented'
  end

  step 'I click on "Ball"' do
    pending 'step not implemented'
  end

  step 'I should see "Ball", "Kugel" inside the Term List' do
    pending 'step not implemented'
  end

  step 'I click on "Toggle scope"' do
    pending 'step not implemented'
  end

  step '"Ball", "Kugel" should be marked as being currently selected' do
    pending 'step not implemented'
  end
end
