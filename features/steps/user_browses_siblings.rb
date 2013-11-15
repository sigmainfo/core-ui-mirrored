class Spinach::Features::UserBrowsesSiblings < Spinach::FeatureSteps
  include AuthSteps
  include Api::Graph::Factory

  def position(node)
    pos = node['transform'].match /\btranslate\((?<x>[\d+-.]+),\s*(?<y>[\d+-.]+)\)/
    { x: pos[:x].to_f, y: pos[:y].to_f }
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

  step '"pool" has a narrower concept "8-ball"' do
    @eight_ball = create_concept_with_label 'eight ball',
      superconcept_ids: [ @pool['id'] ]
  end

  step 'I visit the concept details page for "snooker"' do
    visit "/#{@repository.id}/concepts/#{@snooker['id']}"
  end

  step 'I should see a concept node "snooker"' do
    within('#coreon-concept-map') do
      page.should have_css('.concept-node', text: 'snooker')
      @node = page.find('.concept-node', text: 'snooker')
    end
  end

  step 'this concept node should be horizontally centered below "pocket billiards"' do
    @parent = page.find('.concept-node:not(.placeholder)', text: 'pocket billiards')
    @position = position(@node)
    @position[:x].should be_within(10).of( position(@parent)[:x] )

  end

  step 'I should see a placeholder node representing the siblings of "snooker"' do
    pending 'step not implemented'
  end

  step 'this placeholder should have a count of "2"' do
    pending 'step not implemented'
  end

  step 'this placeholder should be placed on the right next to "snooker"' do
    pending 'step not implemented'
  end

  step 'I should see a placeholder node representing the children of "snooker"' do
    pending 'step not implemented'
  end

  step 'this placeholders should be horizontally centered below "snooker"' do
    pending 'step not implemented'
  end

  step 'I click on "Toggle orientation"' do
    pending 'step not implemented'
  end

  step 'I should still see "snooker"' do
    pending 'step not implemented'
  end

  step 'this concept node should placed on the right next to "pocket billiards"' do
    pending 'step not implemented'
  end

  step 'this placeholder should be placed below "snooker"' do
    pending 'step not implemented'
  end

  step 'this placeholders should be on the right next to "snooker"' do
    pending 'step not implemented'
  end

  step 'a concept "carom billiards" exists' do
    pending 'step not implemented'
  end

  step '"carom billiards" has a narrower concept with English term "five pin billiards"' do
    pending 'step not implemented'
  end

  step '"five pin billiards" has a German term "Billiardkegeln"' do
    pending 'step not implemented'
  end

  step '"carom billiards" has a narrower concept with English term "straight rail billiards"' do
    pending 'step not implemented'
  end

  step '"straight rail billiards" has a German term "Freie Partie"' do
    pending 'step not implemented'
  end

  step '"carom billiards" has a narrower concept with English term "balkline billiards"' do
    pending 'step not implemented'
  end

  step '"balkline billiards" has a German term "Cadre-Disziplin"' do
    pending 'step not implemented'
  end

  step 'I visit the concept details page for "five pin billiards"' do
    pending 'step not implemented'
  end

  step 'I click the placeholder to expand the siblings of "five pin billiards"' do
    pending 'step not implemented'
  end

  step 'I should see "balkline billiards", "five pin billiards", "straight rail billiards" in this order' do
    pending 'step not implemented'
  end

  step 'I select "German" as source language' do
    pending 'step not implemented'
  end

  step 'I should see "Billiardkegeln", "Cadre-Disziplin", "Freie Partie" in this order' do
    pending 'step not implemented'
  end
end
