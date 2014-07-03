# encoding: utf-8
class Spinach::Features::MaintainerAddsTerm < Spinach::FeatureSteps
  include Api::Graph::Factory
  include AuthSteps
  include EditSteps

  step 'a concept exists' do
    @concept = create_concept
  end

  step 'I click "Add term"' do
    click_link 'Add term'
  end
end
