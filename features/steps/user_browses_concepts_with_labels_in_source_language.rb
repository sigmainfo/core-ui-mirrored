class Spinach::Features::UserBrowsesConceptsWithLabelsInSourceLanguage < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps
  include Api::Graph::Factory
  
  def source_language_css
    "#coreon-languages .coreon-select[data-select-name=source_language]"
  end
  
  def dropdown_css
    "#coreon-modal .coreon-select-dropdown"
  end

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

  step 'I click the "Source Language" selector' do
    page.find(source_language_css).click
  end

  step 'I select "None" from the dropdown' do
    within dropdown_css do
      page.find("li", text: "None").click
    end
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
    page.should have_css "table.terms .concept", text: 'gun'
  end

  step 'I should not see the concept hit "Schusswaffe"' do
    page.should_not have_css "table.terms .concept", text: 'Schusswaffe'
  end
  
  step 'I select "German" from the dropdown' do
    within dropdown_css do
      page.find("li", text: "German").click
    end
  end

  step 'I should see the concept hit "Schusswaffe"' do
    page.should have_css "table.terms .concept", text: 'Schusswaffe'
  end

  step 'I should not see the concept hit "gun"' do
    page.should_not have_css "table.terms .concept", text: 'gun'
  end

  step 'I select "French" from the dropdown' do
    within dropdown_css do
      page.find("li", text: "French").click
    end
  end
end
