class Spinach::Features::UserBrowsesSiblings < Spinach::FeatureSteps
  include AuthSteps
  include Api::Graph::Factory
  include LanguageSelectSteps
  include EdgesHelpers

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
      page.find('.placeholder', text: 'carom billiards').find('.icon').click
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

  step 'a concept "Fyodor" exists' do
    @fyodor = create_concept_with_label 'Fyodor'
  end

  step '"Fyodor" has narrower concepts "Dmitri", "Ivan", "Alexei", "Pavel"' do
    %w(Dmitri Ivan Alexei Pavel).each do |label|
      concept = create_concept_with_label label, superconcept_ids: [ @fyodor['id'] ]
      instance_variable_set "@#{label.downcase}".to_sym, concept
    end
  end

  step '"Dmitri" has a broader concept "Adelaida"' do
    @adelaida = create_concept_with_label 'Adelaida', subconcept_ids: [ @dmitri['id'] ]
  end

  step 'both "Ivan" and "Alexei" have a broader concept "Sofia"' do
    @sofia = create_concept_with_label 'Sofia', subconcept_ids: [ @ivan['id'], @alexei['id'] ]
  end

  step '"Pavel" has a broader concept "Lizaveta"' do
    @lizaveta = create_concept_with_label 'Lizaveta', subconcept_ids: [ @pavel['id'] ]
  end

  step 'I visit the concept details page for "Pavel"' do
    visit "/#{@repository.id}/concepts/#{@pavel['id']}"
  end

  step 'I should see "Pavel" horizontally centered below "Fyodor"' do
    within('#coreon-concept-map') do
      page.should have_css('.concept-node:not(.placeholder)', text: 'Fyodor')
      fyodor_node = page.find '.concept-node:not(.placeholder)', text: 'Fyodor'
      fyodor_position = position (fyodor_node )
      page.should have_css('.concept-node:not(.placeholder)', text: 'Pavel')
      pavel_node = page.find '.concept-node:not(.placeholder)', text: 'Pavel'
      pavel_position = position( pavel_node )
      pavel_position[:x].should be_within(10).of( fyodor_position[:x] )
      pavel_position[:y].should > fyodor_position[:y]
    end
  end

  step 'it should be connected both to "Fyodor" and "Lizaveta"' do
    collect_edges.should include('Fyodor -> Pavel', 'Lizaveta -> Pavel')
  end

  step 'I should see a placeholder representing the siblings of "Pavel"' do
    within('#coreon-concept-map') do
      page.should have_css('.placeholder', text: 'Fyodor')
      @placeholder = page.find('.placeholder', text: 'Fyodor')
    end
  end

  step 'it should have a count of "3"' do
    @placeholder.find('.count').should have_text('3')
  end

  step 'I click this placeholder' do
    @placeholder.find('.icon').click
  end

  step 'I should see "Dmitri", "Ivan", and "Alexei"' do
    within('#coreon-concept-map') do
      %w(Dmitri Ivan Alexei).each do |label|
        page.should have_css('.concept-node:not(.placeholder)', text: label)
      end
    end
  end

  step 'I visit the concept details page for "Dmitri"' do
    visit "/#{@repository.id}/concepts/#{@dmitri['id']}"
  end

  step 'I should see "Dmitri" horizontally centered below "Adelaida"' do
    within('#coreon-concept-map') do
      page.should have_css('.concept-node:not(.placeholder)', text: 'Adelaida')
      adelaida_node = page.find '.concept-node:not(.placeholder)', text: 'Adelaida'
      adelaida_position = position (adelaida_node )
      page.should have_css('.concept-node:not(.placeholder)', text: 'Dmitri')
      dmitri_node = page.find '.concept-node:not(.placeholder)', text: 'Dmitri'
      dmitri_position = position( dmitri_node )
      dmitri_position[:x].should be_within(10).of( adelaida_position[:x] )
      dmitri_position[:y].should > adelaida_position[:y]
    end
  end

  step 'it should be connected both to "Fyodor" and "Adelaida' do
    collect_edges.should include('Fyodor -> Dmitri', 'Adelaida -> Dmitri')
  end

  step 'I should see a placeholder node representing the children of "Fyodor"' do
    within('#coreon-concept-map') do
      page.should have_css('.placeholder', text: 'Fyodor')
      @placeholder = page.find('.placeholder', text: 'Fyodor')
    end
  end
end
