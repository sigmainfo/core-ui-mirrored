class Spinach::Features::UserBrowsesSiblings < Spinach::FeatureSteps
  include AuthSteps
  include Api::Graph::Factory
  include LanguageSelectSteps

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

  step 'I visit the concept details page for "pool"' do
    visit "/#{@repository.id}/concepts/#{@pool['id']}"
  end

  step 'I should see a concept node "pool"' do
    within('#coreon-concept-map') do
      page.should have_css('.concept-node.hit', text: 'pool')
      @node = page.find('.concept-node.hit', text: 'pool')
    end
  end

  step 'this concept node should be horizontally centered below "pocket billiards"' do
    within('#coreon-concept-map') do
      parent = page.find('.concept-node:not(.placeholder)', text: 'pocket billiards')
      @node_position = position(@node)
      parent_position = position(parent)
      @node_position[:x].should be_within(10).of( parent_position[:x] )
      @node_position[:y].should > parent_position[:y]
    end
  end

  step 'I should see a placeholder node representing the siblings of "pool"' do
    within('#coreon-concept-map') do
      page.should have_css('.placeholder', text: 'pocket billiards')
      @placeholder = page.find('.placeholder', text: 'pocket billiards')
    end
  end

  step 'this placeholder should have a count of "2"' do
    @placeholder.find('.count').should have_text('2')
  end

  step 'this placeholder should be placed on the right next to "pool"' do
    placeholder_position = position(@placeholder)
    placeholder_position[:y].should be_within(10).of( @node_position[:y] )
    placeholder_position[:x].should > @node_position[:x]
  end

  step 'I should see a placeholder node representing the children of "pool"' do
    within('#coreon-concept-map') do
      page.should have_css('.placeholder', text: 'pool')
      @placeholder = page.find('.placeholder', text: 'pool')
    end
  end

  step 'this placeholder should be horizontally centered below "pool"' do
    placeholder_position = position(@placeholder)
    placeholder_position[:x].should be_within(10).of( @node_position[:x] )
    placeholder_position[:y].should > @node_position[:y]
  end

  step 'I click on "Toggle orientation"' do
    within('#coreon-concept-map') do
      page.click_on "Toggle orientation"
    end
  end

  step 'I should still see "pool"' do
    within('#coreon-concept-map') do
      page.should have_css('.concept-node.hit', text: 'pool')
      @node = page.find('.concept-node.hit', text: 'pool')
    end
  end

  step 'this concept node should placed on the right next to "pocket billiards"' do
    within('#coreon-concept-map') do
      parent = page.find('.concept-node:not(.placeholder)', text: 'pocket billiards')
      parent_position = position(parent)
      @node_position = position(@node)
      @node_position[:y].should be_within(10).of( parent_position[:y] )
      @node_position[:x].should > parent_position[:x]
    end
  end

  step 'this placeholder should be placed below "pool"' do
    placeholder_position = position(@placeholder)
    placeholder_position[:x].should be_within(10).of( @node_position[:x] )
    placeholder_position[:y].should > @node_position[:y]
  end

  step 'this placeholder should be on the right next to "pool"' do
    placeholder_position = position(@placeholder)
    placeholder_position[:y].should be_within(10).of( @node_position[:y] )
    placeholder_position[:x].should > @node_position[:x]  end

  step 'a concept "carom billiards" exists' do
    @carom_billiards = create_concept_with_label 'carom billiards'
  end

  step '"carom billiards" has a narrower concept with English term "five pin billiards"' do
    @five_pin_billiards = create_concept superconcept_ids: [ @carom_billiards['id'] ]
    create_concept_term @five_pin_billiards, lang: 'en', value: 'five pin billiards'
  end

  step '"five pin billiards" has a German term "Billiardkegeln"' do
    create_concept_term @five_pin_billiards, lang: 'de', value: 'Billiardkegeln'
  end

  step '"carom billiards" has a narrower concept with English term "straight rail billiards"' do
    @straight_rail_billiards = create_concept superconcept_ids: [ @carom_billiards['id'] ]
    create_concept_term @straight_rail_billiards, lang: 'en', value: 'straight rail billiards'
  end

  step '"straight rail billiards" has a German term "Freie Partie"' do
    create_concept_term @straight_rail_billiards, lang: 'de', value: 'Freie Partie'
  end

  step '"carom billiards" has a narrower concept with English term "balkline billiards"' do
    @balkline_billiards = create_concept superconcept_ids: [ @carom_billiards['id'] ]
    create_concept_term @balkline_billiards, lang: 'en', value: 'balkline billiards'
  end

  step '"balkline billiards" has a German term "Cadre-Disziplin"' do
    create_concept_term @balkline_billiards, lang: 'de', value: 'Cadre-Disziplin'
  end

  step 'I visit the concept details page for "five pin billiards"' do
    visit "/#{@repository.id}/concepts/#{@five_pin_billiards['id']}"
  end

  step 'I click the placeholder to expand the siblings of "five pin billiards"' do
    within('#coreon-concept-map') do
      page.should have_css('.placeholder', text: 'carom billiards')
      page.find('.placeholder', text: 'carom billiards').click
    end
  end

  step 'I should see "balkline billiards", "five pin billiards", "straight rail billiards" in this order' do
    within('#coreon-concept-map') do
      page.should have_css('.concept-node', text: 'balkline billiards')
      first  = position page.find('.concept-node', text: 'balkline billiards')
      second = position page.find('.concept-node', text: 'five pin billiards')
      last   = position page.find('.concept-node', text: 'straight rail billiards')
      first[:x].should  < second[:x]
      second[:x].should < last[:x]
    end
  end

  step 'I select "German" as source language' do
    page.find('#coreon-languages .coreon-select[data-select-name=source_language]').click
    within '#coreon-modal .coreon-select-dropdown' do
      page.find('li', text: 'German').click
    end
  end

  step 'I should see "Billiardkegeln", "Cadre-Disziplin", "Freie Partie" in this order' do
    within('#coreon-concept-map') do
      page.should have_css('.concept-node', text: 'Billiardkegeln')
      first  = position page.find('.concept-node', text: 'Billiardkegeln')
      second = position page.find('.concept-node', text: 'Cadre-Disziplin')
      last   = position page.find('.concept-node', text: 'Freie Partie')
      first[:x].should  < second[:x]
      second[:x].should < last[:x]
    end
  end
end
