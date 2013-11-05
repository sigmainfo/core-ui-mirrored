class Spinach::Features::UserFocusesSelection < Spinach::FeatureSteps
  include AuthSteps
  include Api::Graph::Factory

  step 'I have selected a repository "Billiards"' do
    @repository.update_attributes name: 'Billiards'
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
    visit "/#{@repository.id}"
  end

  step 'I should see the repository node being vertically centered' do
    pending 'step not implemented'
  end

  step 'it should be slightly above the center' do
    pending 'step not implemented'
  end

  step 'I click "Toggle orientation"' do
    pending 'step not implemented'
  end

  step 'I should see the repository node being horizontally centered' do
    pending 'step not implemented'
  end

  step 'it should be slightly left of the center' do
    pending 'step not implemented'
  end

  step 'I click the placeholder node' do
    pending 'step not implemented'
  end

  step 'the repository node should have moved up by a level' do
    pending 'step not implemented'
  end

  step 'I click on pocket billiards' do
    pending 'step not implemented'
  end

  step 'pocket billiards should be horizontally and vertically centered' do
    pending 'step not implemented'
  end

  step 'I search for "billiard"' do
    pending 'step not implemented'
  end

  step '"pocket billiards" and "English billiards" should be visible' do
    pending 'step not implemented'
  end
end
