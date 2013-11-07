class Spinach::Features::UserBrowsesTermsInSourceAndTargetLanguage < Spinach::FeatureSteps
  include AuthSteps
  include LanguageSelectSteps
  include Api::Graph::Factory
  
  step 'a concept' do
    @concept = create_concept nil
  end

  step 'this concept has the following English terms: "gun", "firearm"' do
    create_concept_term @concept, value: 'gun', lang: 'en'
    create_concept_term @concept, value: 'firearm', lang: 'en'
  end

  step 'this concept has the following German terms: "Schusswaffe", "Flinte"' do
    create_concept_term @concept, value: 'Schusswaffe', lang: 'de'
    create_concept_term @concept, value: 'Flinte', lang: 'de'
  end

  step 'this concept hat the following Russian terms: "пистолет", "огнестрельное оружие"' do
    create_concept_term @concept, value: 'пистолет', lang: 'ru'
    create_concept_term @concept, value: 'огнестрельное оружие', lang: 'ru'
  end

  step 'this concept has the following Korean terms: "산탄 총", "총"' do
    create_concept_term @concept, value: '산탄 총', lang: 'ko'
    create_concept_term @concept, value: '총', lang: 'ko'
  end

  step 'I am on this concept\'s page' do
    visit "/#{@repository.id}/concepts/#{@concept['id']}"
  end

  step 'I should see the Terms in following language order: "Russian", "English", "Korean", "German"' do
    sleep 0.2
    page.all(".concept .terms h3").map{|n| n.text}.should == ["RU", "EN", "KO", "DE"]
  end

  step 'I should see the Terms in following language order: "German", "Russian", "English", "Korean"' do
    sleep 0.2
    page.all(".concept .terms h3").map{|n| n.text}.should == [ "DE", "RU", "EN", "KO"]
  end

  step 'I should see the Terms in following language order: "German", "English", "Russian", "Korean"' do
    sleep 0.2
    page.all(".concept .terms h3").map{|n| n.text}.should == ["DE", "EN", "RU", "KO"]
  end

  step 'I should see the Terms in following language order: "English", "Russian", "Korean", "German"' do
    sleep 0.2
    page.all(".concept .terms h3").map{|n| n.text}.should == ["EN", "RU", "KO", "DE"]
  end

  step 'I should see the Terms in following language order: "French", "English", "Russian", "Korean", "German"' do
    sleep 0.2
    page.all(".concept .terms h3").map{|n| n.text}.should == ["FR", "EN", "RU", "KO", "DE"]
  end

  step 'I should see "No terms for this language" in the French section' do
    page.find(".concept .terms section.fr .no-terms").should have_text "No terms for this language"
  end
end