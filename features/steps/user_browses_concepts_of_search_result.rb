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
    @ballistics = @concept = create_concept_with_label 'ballistics'
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

  step 'I should see an empty listing of search results' do
    page.should have_css('.concept-list')
    page.should have_no_css('.concept-list .concept-list-item')
  end

  step 'it should contain a message: \'No concepts found for "gun"\'' do
    page.find('.concept-list tbody').text.should == 'No concepts found for "gun"'
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
      page.should have_css('.concept-list-item th',
                            text: 'BROADER', count: 3)
    end
  end

  step 'it should contain "equipment" and "billiards" for "ball"' do
    within '.concept-list' do
      ball = page.all('.concept-list-item .label td a').find do |a|
        a.text == 'ball'
      end.find :xpath, 'ancestor::*[contains(@class, "concept-list-item")]'
      labels = ball.all('tr.broader td a').map(&:text)
      labels.should == ['billiards', 'equipment']
    end
  end

  step 'it should be empty for "ballistics" and "balloon"' do
    within '.concept-list' do
      %w(ballistics balloon).each do |label|
        concept = page.all('.concept-list-item .label td a').find do |a|
          a.text == label
        end.find :xpath, 'ancestor::*[contains(@class, "concept-list-item")]'
        concept.should have_no_css('tr.broader td a')
      end
    end
  end

  step '"ballistics" should have a section "DEFINITION"' do
    within '.concept-list' do
      @ballistics_row = page.all('.concept-list-item .label td a').find do |a|
        a.text == 'ballistics'
      end.find :xpath, 'ancestor::*[contains(@class, "concept-list-item")]'
      @ballistics_row.should have_css('tr.definition th', text: 'DEFINITION')
    end

  end

  step 'it should contain "Mechanics that describe behavior of projectiles"' do
    definition = @ballistics_row.find('tr.definition td').text
    definition.should == 'Mechanics that describe behavior of projectiles'
  end

  step '"DEFINITION" should not be displayed for "ball" and "balloon"' do
    within '.concept-list' do
      %w(ball balloon).each do |label|
        concept = page.all('.concept-list-item .label td a').find do |a|
          a.text == label
        end.find :xpath, 'ancestor::*[contains(@class, "concept-list-item")]'
        concept.should have_no_css('th', text: 'Definition')
      end
    end

  end

  step '"ball" should have an English term "billiard ball"' do
    pending 'step not implemented'
  end

  step '"ball" should have a German term "Billiardkugel"' do
    pending 'step not implemented'
  end

  step 'I click on "ballistics"' do
    within '.concept-list' do
      page.find('.concept-list-item .label td a', text: 'ballistics').click
    end
  end

  step 'I should see the details for concept "ballistics"' do
    page.should have_css('.concept.show .concept-head .concept-label', text: 'ballistics')
  end

  step 'I should be on the concept details page for "ballistics"' do
    current_path.should == "/#{@repository.id}/concepts/#{@ballistics['id']}"
  end
end
