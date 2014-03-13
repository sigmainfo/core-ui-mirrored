class Spinach::Features::UserBrowsesTermHitsInSourceLanguage < Spinach::FeatureSteps

  include AuthSteps
  include LanguageSelectSteps
  include SearchSteps
  include Api::Graph::Factory

  step 'a concept with English term "billiards" exists' do
    @concept = create_concept terms: [ {lang: 'en', value: 'billiards'} ]
  end

  step 'this concept has a German term "Billiard"' do
    create_concept_term @concept, value: 'Billiard', lang: 'de'
  end

  step 'a concept with English term "billiards table" exists' do
    @concept = create_concept terms: [ {lang: 'en', value: 'billiards table'} ]
  end

  step 'this concept has a German term "Billiardtisch"' do
    create_concept_term @concept, value: 'Billiardtisch', lang: 'de'
  end

  step 'a concept with English term "billiard ball" exists' do
    @concept = create_concept terms: [ {lang: 'en', value: 'billiard ball'} ]
  end

  step 'this concept has German terms "Billiardkugel" and "Ball"' do
    create_concept_term @concept, value: 'Billiardkugel', lang: 'de'
    create_concept_term @concept, value: 'Ball', lang: 'de'
  end

  step 'a concept with English term "8-ball" exists' do
    @concept = @eight_ball = create_concept terms: [ {lang: 'en', value: '8-ball'} ]
  end

  step 'this concept has a German term "8er-Ball"' do
    create_concept_term @concept, value: '8er-Ball', lang: 'de'
  end

  step 'a concept with English term "high bridge" exists' do
    @concept = create_concept terms: [ {lang: 'en', value: 'high bridge'} ]
  end

  step 'this concept has a German term "Brücke über einen Ball"' do
    create_concept_term @concept, value: 'Brücke über einen Ball', lang: 'de'
  end

  step 'the "Term List" widget should contain 3 items' do
    @terms = page.find('.widget .titlebar h3', text: 'Term List').find(:xpath, '../..')
    @terms.should have_css('tbody tr', count: 3)
  end

  step 'these should be "8-ball" "billiard ball", and "high bridge"' do
    @terms.all('td.source').map(&:text).should == [ '8-ball', 'billiard ball', 'high bridge' ]
  end

  step 'the "Term List" widget should contain 4 items' do
    @terms.should have_css('tbody tr', count: 4)
  end

  step 'these should be "8er-Ball", "Ball", "Billiardkugel", and "Brücke über einen Ball"' do
    @terms.all('td.source').map(&:text).should == [
      '8er-Ball', 'Ball', 'Billiardkugel', 'Brücke über einen Ball'
    ]
  end

  step 'I click the first item' do
    @terms.find('td.source a', text: '8er-Ball').click
  end

  step 'I should be on the concept details page for "8-ball"' do
    current_path.should end_with("concepts/#{@eight_ball['id']}")
  end

  step 'the "Term List" widget should contain "8er-Ball" only' do
    @terms.should have_css('tbody tr', count: 1)
    @terms.find('tr td.source a').text().should == '8er-Ball'
  end
end
