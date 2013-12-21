class Spinach::Features::UserBrowsesConceptsWithLabelsInSourceLanguage < Spinach::FeatureSteps
  include AuthSteps
  include LanguageSelectSteps
  include SearchSteps
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

  step 'I enter "firearm" in the search field' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "firearm"
    end
  end

  step 'I click the search button' do
    within "#coreon-search" do
      find('input[type="submit"]').click
    end
  end

  step 'I should see the concept hit "gun"' do
    page.should have_css ".concept-list .label .concept-label", text: 'gun'
  end

  step 'I should see a concept node "gun" inside the concept map' do
    within '#coreon-concept-map' do
      page.should have_css('.concept-node', text: 'gun')
    end
  end

  step 'I should not see the concept hit "Schusswaffe"' do
    page.should_not have_css ".concept-list .label .concept-label", text: 'Schusswaffe'
  end


  step 'I should see the concept hit "Schusswaffe"' do
    page.should have_css ".concept-list .label .concept-label", text: 'Schusswaffe'
  end

  step 'I should see a concept node "Schusswaffe" inside the concept map' do
    within '#coreon-concept-map' do
      page.should have_css('.concept-node', text: 'Schusswaffe')
    end
  end

  step 'I should not see the concept hit "gun"' do
    page.should_not have_css "table.terms .concept", text: 'gun'
  end
end
