class Spinach::Features::UserBrowsesConceptsOfSearchResult < Spinach::FeatureSteps
  include AuthSteps
  include Api::Graph::Factory
  include SearchSteps
  include LanguageSelectSteps

  step 'a concept with label "ball" exists' do
    @concept = create_concept_with_label 'ball'
  end

  step 'this concept has broader concepts "equipment" and "billiards"' do
    @parent = create_concept_with_label 'equipment'
    link_narrower_to_broader @concept, @parent
    @parent = create_concept_with_label 'billiards'
    link_narrower_to_broader @concept, @parent
  end

  step 'this concept has an English term "billiard ball"' do
    create_concept_term @concept, value: 'billiard ball', lang: 'en'
  end

  step 'this concept has German terms "Billiardkugel", "Kugel"' do
    create_concept_term @concept, value: 'Billiardkugel', lang: 'de'
    create_concept_term @concept, value: 'Kugel', lang: 'de'
  end

  step 'a concept with label "ballistics" exists' do
    @concept = create_concept_with_label 'ballistics'
  end

  step 'it is defined as "Mechanics that describe behavior of projectiles"' do
    create_concept_property @concept, {
      key: 'definition',
      value: 'Mechanics that describe behavior of projectiles'
    }
  end

  step 'this concept has a German term "Ballistik"' do
    create_concept_term @concept, value: 'Ballistik', lang: 'de'
  end

  step 'a concept with label "balloon" exists' do
    @concept = create_concept_with_label 'balloon'
  end

  step 'a concept with label "game play" exists' do
    @concept = create_concept_with_label 'game play'
  end

  step 'I should see a listing of search results' do
    page.should have_css('.concept-list .concept-list-item')
  end

  step 'it should display labels for "ball", "ballistics", "balloon"' do
    within '.concept-list' do
      %w(ball ballistics balloon).each do |label|
        page.should have_css('.concept-list-item .label', text: label)
      end
    end
  end

  step 'I should be on the search results page for query "ball"' do
    current_path.should == "/#{@repository.id}/concepts/search/ball"
  end

  step 'each of them should have a section "BROADER"' do
    within '.concept-list' do
      page.should have_css('.concept-list-item thead td',
                            text: 'BROADER', count: 3)
    end
  end

  step '"ball" should have an English term "billiard ball"' do
    pending 'step not implemented'
  end

  step '"ball" should have a German term "Billiardkugel"' do
    pending 'step not implemented'
  end

  step 'I click on "ballistics"' do
    pending 'step not implemented'
  end

  step 'I should see the details for concept "ballistics"' do
    pending 'step not implemented'
  end

  step 'I should be on the concept details page for "ballistics"' do
    pending 'step not implemented'
  end
end
