class Spinach::Features::UserBrowsesChildNodes < Spinach::FeatureSteps
  include AuthSteps
  include Factory
  include EdgesHelpers

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

  step 'I should see the repository node within the concept map' do
    within('#coreon-concept-map') do
      page.should have_css('.concept-node.repository-root')
    end
  end

  step 'I should see a placeholder node deriving from it' do
    within('#coreon-concept-map') do
      page.should have_css('.placeholder', text: 'Billiards')
      @placeholder = page.find('.placeholder', text: 'Billiards')
    end
    collect_placeholder_edges.should include('+[Billiards]')
  end

  step 'this placeholder should have an object count of "2"' do
    within('#coreon-concept-map') do
      @placeholder.find('.count').should have_text('2')
    end
  end

  step 'I click this placeholder' do
    @placeholder.find('.icon').click
  end

  step 'I should see two concept nodes "pocket billiards" and "carom billiards"' do
    page.execute_script '''
      $("#coreon-concept-map").height(700);
      $("#coreon-widgets").width(900);
      $("#coreon-concept-map svg").height(700);
      $("#coreon-concept-map svg").width(900);
    '''
    within('#coreon-concept-map') do
      page.should have_css('.concept-node', text: 'pocket billiards')
      page.should have_css('.concept-node', text: 'carom billiards')
    end
  end

  step 'I should not see this placeholder anymore' do
    within('#coreon-concept-map') do
      page.should have_no_css('.placeholder', text: 'Billiards')
    end
  end

  step 'both concepts should be connected to the repository node' do
    collect_edges.should include('Billiards -> pocket billiards', 'Billiards -> carom billiards')
  end

  step 'I should see a placeholder deriving from each of them' do
    within('#coreon-concept-map') do
      page.should have_css('.placeholder', text: 'pocket billiards')
      page.should have_css('.placeholder', text: 'carom billiards')
    end
    collect_placeholder_edges.should include('+[pocket billiards]', '+[carom billiards]')
  end

  step 'I should see object count "1" for placeholder connected to "carom billiards"' do
    within('#coreon-concept-map') do
      page.find('.placeholder', text: 'carom billiards').find('.count').should have_text('1')
    end
  end

  step 'I should see object count "3" for placeholder connected to "pocket billiards"' do
    within('#coreon-concept-map') do
      page.find('.placeholder', text: 'pocket billiards').find('.count').should have_text('3')
    end
  end

  step 'I click the placeholder connected to "pocket billiards"' do
    page.find('.placeholder', text: 'pocket billiards').find('.icon').click
  end

  step 'I should see three concept nodes "pool", "snooker", "English billiards"' do
    within('#coreon-concept-map') do
      page.should have_css('.concept-node', text: 'pool')
      page.should have_css('.concept-node', text: 'snooker')
      page.should have_css('.concept-node', text: 'English billiards')
    end
  end

  step 'these should be connected to "pocket billiards"' do
    collect_edges.should include('pocket billiards -> pool',
                                 'pocket billiards -> snooker',
                                 'pocket billiards -> English billiards')
  end

  step 'I should see a placeholder deriving from "pool" and "carom billiards"' do
    within('#coreon-concept-map') do
      page.should have_css('.placeholder', text: 'pool')
      page.should have_css('.placeholder', text: 'carom billiards')
    end
  end

  step 'I should not see the placeholder connected to "pocket billiards" anymore' do
    within('#coreon-concept-map') do
      page.should have_no_css('.placeholder', text: 'pocket billiards')
    end

  end

  step 'I should see object count "2" for placeholder connected to "pool"' do
    page.find('.placeholder', text: 'pool').find('.count').should have_text('2')
  end
end
