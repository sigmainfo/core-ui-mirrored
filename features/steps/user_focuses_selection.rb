class Spinach::Features::UserFocusesSelection < Spinach::FeatureSteps
  include AuthSteps
  include Factory

  def transform(selector, options = {})
    page.should have_css(selector)
    page.find(selector, options)['transform']
  end

  def position(selector, options = {})
    transform(selector, options).match /\btranslate\((?<x>[\d+-.]+),\s*(?<y>[\d+-.]+)\)/
  end

  def offset(selector, options = {})
    map = position '#coreon-concept-map g.concept-map'
    node = position selector, options
    {
      x: map['x'].to_i + node['x'].to_i,
      y: map['y'].to_i + node['y'].to_i
    }
  end

  def viewport
    {
      width:  page.evaluate_script(%|$("#coreon-concept-map svg").innerWidth()|).to_i,
      height: page.evaluate_script(%|$("#coreon-concept-map svg").innerHeight()|).to_i
    }
  end

  def center
    v = viewport
    {
      x: v[:width] / 2,
      y: v[:height] / 2
    }
  end

  step 'I have selected a repository "Billiards"' do
    current_repository.update_attributes name: 'Billiards'
  end

  step 'a concept "pocket billiards" exists' do
    @pocket_billiards = create_concept_with_label 'pocket billiards'
  end

  step 'this concept has narrower concepts "pool", "snooker", "English billiards"' do
    @pool = create_concept_with_label 'pool',
      superconcept_ids: [ @pocket_billiards['id'] ]
    @snooker = create_concept_with_label 'snooker',
      superconcept_ids: [ @pocket_billiards['id'] ]
    @english = create_concept_with_label 'English billiards',
      superconcept_ids: [ @pocket_billiards['id'] ]
  end

  step '"pool" has narrower concepts "8-ball", "nine ball"' do
    @eight_ball = create_concept_with_label 'eight ball',
      superconcept_ids: [ @pool['id'] ]
    @nine_ball = create_concept_with_label 'nine ball',
      superconcept_ids: [ @pool['id'] ]
  end

  step 'a concept "carom billiards" exists' do
    @carom_billiards = create_concept_with_label 'carom billiards'
  end

  step 'this concept has a narrower concept "five pin billiards"' do
    @five_pin_billiards = create_concept_with_label 'five pin billiards',
      superconcept_ids: [ @carom_billiards['id'] ]
  end

  step 'I visit the repository root page' do
    visit "/#{current_repository.id}"
  end

  step 'I should see the repository node being vertically centered' do
    page.should have_css('#coreon-concept-map .concept-node.repository-root')
    @offset = offset('#coreon-concept-map .concept-node.repository-root')
    @offset[:x].should == 0
  end

  step 'it should be somewhat above the center of the viewport' do
    @viewport = viewport
    @offset[:y].should < -80
  end

  step 'I click "Toggle orientation"' do
    click_link "Toggle orientation"
    sleep 3
  end

  step 'I should see the repository node being horizontally centered' do
    @offset = offset('#coreon-concept-map .concept-node.repository-root')
    @offset[:y].should == 0
  end

  step 'it should be somewhat left of the center of the viewport' do
    @offset[:x].should < 200
  end

  step 'I click the placeholder node' do
    page.find('#coreon-concept-map .concept-node.placeholder').find('.icon').click
  end

  step 'I click on pocket billiards' do
    page.should have_css('#coreon-concept-map .concept-node:not(.placeholder)', text: 'pocket billiards')
    pocket_billiards = page.find('#coreon-concept-map .concept-node:not(.placeholder)', text: 'pocket billiards')
    pocket_billiards.find('a').click
    sleep 1
  end

  step 'pocket billiards should be horizontally and vertically centered' do
    offset = offset('#coreon-concept-map .concept-node.hit')
    offset[:x].should == 0
    offset[:y].should == 0
  end
end
