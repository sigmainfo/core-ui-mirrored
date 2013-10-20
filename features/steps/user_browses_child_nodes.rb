class Spinach::Features::UserBrowsesChildNodes < Spinach::FeatureSteps
  include AuthSteps
  include Api::Graph::Factory
  include EdgesHelpers

  step 'I have selected a repository "Billiards"' do
    @repository.update_attributes name: "Billiards"
  end

  step 'a concept "pocket billiards" exists' do
    @pocket_billiards = create_concept_with_label "pocket billiards"
  end

  step 'this concept has narrower concepts "pool", "snooker", "English billiards"' do
    @pool = create_concept_with_label "pool", superconcept_ids: [ @pocket_billiards["id"] ]
    @snooker = create_concept_with_label "snooker", superconcept_ids: [ @pocket_billiards["id"] ]
    @english = create_concept_with_label "English billiards", superconcept_ids: [ @pocket_billiards["id"] ]
  end

  step '"pool" has narrower concepts "8-ball", "nine ball"' do
    @eight_ball = create_concept_with_label "eight ball", superconcept_ids: [ @pool["id"] ]
    @nine_ball = create_concept_with_label "nine ball", superconcept_ids: [ @pool["id"] ]
  end

  step 'a concept "carom billiards" exists' do
    @carom_billiards = create_concept_with_label "carom billiards"
  end

  step 'this concept has a narrower concept "five pin billiards"' do
    @five_pin_billiards = create_concept_with_label "five pin billiards", superconcept_ids: [ @carom_billiards["id"] ]
  end

  step 'I visit the repository root page' do
    visit "/#{@repository.id}"
  end

  step 'I should see the repository node within the concept map' do
    within("#coreon-concept-map") do
      page.should have_css(".concept-node.repository-root")
    end
  end

  step 'I should see a placeholder node deriving from it' do
    within("#coreon-concept-map") do
      page.should have_css(".concept-node.placeholder")
    end
    collect_placeholder_edges.should include("+[Billiards]")
  end

  step 'this placeholder should have no object count' do
    pending 'step not implemented'
  end

  step 'I click this placeholder' do
    pending 'step not implemented'
  end

  step 'I should not see this placeholder anymore' do
    pending 'step not implemented'
  end

  step 'I should see two concept nodes "pocket billiards" and "carom billiards"' do
    pending 'step not implemented'
  end

  step 'both should be connected to the repository node' do
    pending 'step not implemented'
  end

  step 'I should see a placeholder deriving from each of them' do
    pending 'step not implemented'
  end

  step 'I should see object count "1" for placeholder connected to "carom billiards"' do
    pending 'step not implemented'
  end

  step 'I should see object count "3" for placeholder connected to "pocket billiards"' do
    pending 'step not implemented'
  end

  step 'I click the placeholder connected to "pocket billiards"' do
    pending 'step not implemented'
  end

  step 'I should see three concept nodes "pool", "snooker", "English billiards"' do
    pending 'step not implemented'
  end

  step 'these should be connected to "pocket billiards"' do
    pending 'step not implemented'
  end

  step 'I should see a placeholder deriving from "pool" only' do
    pending 'step not implemented'
  end

  step 'I should see object count "2" for placeholder connected to "pool"' do
    pending 'step not implemented'
  end
end
