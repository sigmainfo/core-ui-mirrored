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

  step 'a concept with label "ball-shaped" exists' do
    @ball_shaped = @concept = create_concept_with_label 'ball-shaped'
  end

  step 'it is defined as "a spherical object"' do
    create_concept_property @concept, {
      key: 'definition',
      value: 'a spherical object'
    }
  end

  step 'this concept has a German term "kugelförmig"' do
    create_concept_term @concept, value: 'kugelförmig', lang: 'de'
  end

  step 'a concept with label "ball and chain" exists' do
    @concept = create_concept_with_label 'ball and chain'
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

  step 'it should display labels for "ball", "ball-shaped", "ball and chain"' do
    within '.concept-list' do
      ['ball', 'ball-shaped', 'ball and chain'].each do |label|
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

  step 'it should be empty for "ball-shaped" and "ball and chain"' do
    within '.concept-list' do
      ['ball-shaped', 'ball and chain'].each do |label|
        concept = page.all('.concept-list-item .label td a').find do |a|
          a.text == label
        end.find :xpath, 'ancestor::*[contains(@class, "concept-list-item")]'
        concept.should have_no_css('tr.broader td a')
      end
    end
  end

  step '"ball-shaped" should have a section "DEFINITION"' do
    within '.concept-list' do
      @ball_shaped_row = page.all('.concept-list-item .label td a').find do |a|
        a.text == 'ball-shaped'
      end.find :xpath, 'ancestor::*[contains(@class, "concept-list-item")]'
      @ball_shaped_row.should have_css('tr.definition th', text: 'DEFINITION')
    end

  end

  step 'it should contain "a spherical object"' do
    definition = @ball_shaped_row.find('tr.definition td').text
    definition.should == 'a spherical object'
  end

  step '"DEFINITION" should not be displayed for "ball" and "ball and chain"' do
    within '.concept-list' do
      ['ball', 'ball and chain'].each do |label|
        concept = page.all('.concept-list-item .label td a').find do |a|
          a.text == label
        end.find :xpath, 'ancestor::*[contains(@class, "concept-list-item")]'
        concept.should have_no_css('th', text: 'Definition')
      end
    end

  end

  step 'I should see "ball", "ball-shaped", and "ball and chain" as search results' do
    within '.concept-list' do
      ['ball', 'ball-shaped', 'ball and chain'].each do |label|
        page.should have_css('.concept-list-item .label', text: label)
      end
    end
  end

  step 'I should see language "EN" inside each of them' do
    within '.concept-list' do
      page.should have_css('.concept-list-item th',
                            text: 'EN', count: 3)
    end
  end

  step 'it should contain "billiard ball" for "ball"' do
    within '.concept-list' do
      ball = page.all('.concept-list-item .label td a').find do |a|
        a.text == 'ball'
      end.find :xpath, 'ancestor::*[contains(@class, "concept-list-item")]'
      ball.find('tr.lang td').text.should == 'billiard ball'
    end
  end

  step 'I should not see language "EN" inside any of them' do
    within '.concept-list' do
      page.should have_no_css('.concept-list-item th', text: 'EN')
    end
  end

  step 'I should see language "DE" inside each of them' do
    within '.concept-list' do
      page.should have_css('.concept-list-item th',
                            text: /^DE$/, count: 3)
    end
  end

  step 'it should contain "Billiardkugel, Kugel" for "ball"' do
    within '.concept-list' do
      ball = page.find('.concept-list-item .label td a', text: /^ball$/).find :xpath,
        'ancestor::*[contains(@class, "concept-list-item")]'
      ball.find('tr.lang td').text.should == 'Billiardkugel | Kugel'
    end
  end

  step 'it should contain "kugelförmig" for "ball-shaped"' do
    within '.concept-list' do
      ball_shaped = page.find('.concept-list-item .label td a',
        text: 'ball-shaped').find :xpath,
        'ancestor::*[contains(@class, "concept-list-item")]'
      ball_shaped.find('tr.lang td').text.should == 'kugelförmig'
    end
  end

  step 'it should be empty for "ball and chain"' do
    within '.concept-list' do
      ball_and_chain = page.find('.concept-list-item .label td a',
        text: 'ball and chain').find :xpath,
        'ancestor::*[contains(@class, "concept-list-item")]'
      ball_and_chain.find('tr.lang td').text.should == ''
    end
  end

  step 'I should see languages "DE", "EN" inside each of them' do
    within '.concept-list' do
      page.should have_css('.concept-list-item th',
                            text: /^DE$/, count: 3)
      page.should have_css('.concept-list-item th',
                            text: 'EN', count: 3)
    end
  end

  step 'I click on "ball-shaped"' do
    within '.concept-list' do
      page.find('.concept-list-item .label td a', text: 'ball-shaped').click
    end
  end

  step 'I should see the details for concept "ball-shaped"' do
    page.should have_css('.concept.show .concept-head .concept-label', text: 'ball-shaped')
  end

  step 'I should be on the concept details page for "ball-shaped"' do
    current_path.should == "/#{@repository.id}/concepts/#{@ball_shaped['id']}"
  end
end
