class Spinach::Features::MaintainerManagesConnectionsInConceptMap < Spinach::FeatureSteps

  include AuthSteps
  include Factory
  # include EditSteps
  include Resources
  include Selectors

  def main_view
    find '#coreon-main'
  end

  step 'I can move the map with drag and drop on empty space' do
    pending 'step not implemented'
  end

  step 'I can zoom in the map' do
    pending 'step not implemented'
  end

  step 'I click on the "intra-EU transport" concept node' do
    pending 'step not implemented'
  end

  step 'I am still in the root node page' do
    pending 'step not implemented'
  end

  step 'in this view there is a "Reset" button' do
    pending 'step not implemented'
  end

  step 'in this view there is a "Cancel" button' do
    pending 'step not implemented'
  end

  step 'in this view there is a "Save relations" button' do
    pending 'step not implemented'
  end

  step 'I drag concept "pipeline transport" on the "destination of transport" concept' do
    pending 'step not implemented'
  end

  step 'I see concept "pipeline transport" connected with a thick line with concept "destination of transport"' do
    pending 'step not implemented'
  end

  step 'I see concept "pipeline transport" connected with a dotted line with concept "mode of transport"' do
    pending 'step not implemented'
  end

  step 'I click "Save relations"' do
    pending 'step not implemented'
  end

  step 'I am not in edit mode' do
    pending 'step not implemented'
  end

  step 'I see concept "pipeline transport" connected with concept "destination of transport"' do
    pending 'step not implemented'
  end

  step 'I see concept "intra-EU transport" connected with concept "destination of transport"' do
    pending 'step not implemented'
  end

  step 'I see concept "mode of transport" does not heave any subconcepts' do
    pending 'step not implemented'
  end

  step 'I click "Reset"' do
    pending 'step not implemented'
  end

  step 'I am in edit mode' do
    pending 'step not implemented'
  end

  step 'I see concept "destination of transport" connected with concept "intra-EU transport"' do
    pending 'step not implemented'
  end

  step 'I see concept "mode of transport" connected with concept "pipeline transport"' do
    pending 'step not implemented'
  end

  step 'I see concept "pipeline transport" has no connection with concept "destination of transport"' do
    pending 'step not implemented'
  end

  step 'I click "Cancel"' do
    pending 'step not implemented'
  end


  step 'a concept with label "destination of transport" exists' do
    @superconcept1 = create_concept_with_label "destination of transport"
  end

  step 'the concept "destination of transport" has "intra-EU transport" as a subconcept' do
    @concept1 = create_concept_with_label "intra-EU transport",
      superconcept_ids: [@superconcept1['id']]
  end

  step 'a concept with label "mode of transport" exists' do
    @superconcept2 = create_concept_with_label "mode of transport"
  end

  step 'the concept "mode of transport" has "pipeline transport" as a subconcept' do
    @concept2 = create_concept_with_label "pipeline transport",
       superconcept_ids: [@superconcept2['id']]
  end

  step 'I should see a widget "Concept Map"' do
    #page.should have_selector( "#coreon-concept-map h3", text: 'Concept Map' )
    page.should have_selector( :widget, 'Concept Map' )
    @current = find( :widget, 'Concept Map' )
  end

  step 'I click on "Maximize" inside the widget "Concept Map"' do
    within :widget, 'Concept Map' do
      click_on 'Maximize'
    end

  end

  step 'I see a concept map inside the main view' do
    pending 'step not implemented'
  end

  step 'I click the "Edit mode" button' do
    pending 'step not implemented'

  end
end
