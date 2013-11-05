class Spinach::Features::UserSearchesInSourceAndTargetLanguage < Spinach::FeatureSteps
  
  include AuthSteps
  include LanguageSelectSteps
  include Api::Graph::Factory
  
  
  step 'a concept defined as "A portable firearm"' do
    @concept = create_concept properties: [{key: 'definition', value: 'A portable firearm'}] 
  end

  step 'this concept has the English term "gun"' do
    create_concept_term @concept, value: 'gun', lang: 'en'
  end

  step 'this concept has the German term "Schusswaffe"' do
    create_concept_term @concept, value: 'Schusswaffe', lang: 'de'
  end

  step 'this concept has the French term "arme à feu"' do
    create_concept_term @concept, value: 'arme à feu', lang: 'fr'
  end

  step 'this concept hat the Russian term "пистолет"' do
    create_concept_term @concept, value: 'пистолет', lang: 'ru'
  end

  step 'I enter "пистолет" in the search field' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "пистолет"
    end
  end
  
  step 'I enter "Schusswaffe" in the search field' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "Schusswaffe"
    end
  end

  step 'I click the search button' do
    within "#coreon-search" do
      find('input[type="submit"]').click
    end
  end
  
  step 'I should see 1 term hit' do
    page.find('.search-results table.terms td.term')
    page.all('.search-results table.terms td.term').count.should == 1
  end
  
  step 'I should see 1 concept hit' do
    page.all('.search-results table.concepts td.concept.label').count.should == 1
  end
  
  
  step 'I should see no term hit' do
    page.should_not have_css('.search-results table.terms td.term')
  end
  
  step 'I should see no concept hit' do
    page.should_not have_css('.search-results table.concepts td.concept.label')
  end
end
