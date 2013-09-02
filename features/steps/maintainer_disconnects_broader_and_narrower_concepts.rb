# encoding: utf-8

class MaintainerDisconnectsBroaderAndNarrowerConcepts < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include SearchSteps
  include Api::Graph::Factory

  step 'a concept with label "panopticum" exists' do
    @concept = create_concept_with_label "panopticum"
  end

  step 'a concept with label "surveillance" exists' do
    @concept = create_concept_with_label "surveillance"
  end


