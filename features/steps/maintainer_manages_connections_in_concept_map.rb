class Spinach::Features::MaintainerManagesConnectionsInConceptMap < Spinach::FeatureSteps

  include AuthSteps
  include Factory
  include Resources
  include Selectors

  step 'I can move the map with drag and drop on empty space' do
    pending 'step not implemented'
  end

  step 'I can zoom in the map' do
    page.find('#coreon-concept-map .zoom-in').click
    #page.find('#coreon-concept-map .zoom-out').click
  end

  step 'I click on the "intra-EU transport" concept node' do
    find(".concept-node.placeholder").click
    sleep 1
    # first(".concept-node.placeholder").click
    # first(".concept-node.placeholder").click
    all(".concept-node.placeholder").each(&:click)
  end

  step 'I am still in the root node page' do
    pending 'step not implemented'
  end

  step 'in this view there is a "Reset" button' do
    page.find("#coreon-concept-map .reset-map").should have_content("Reset")
  end

  step 'in this view there is a "Cancel" button' do
    page.find('#coreon-concept-map .cancel-map').should have_content("Cancel")
  end

  step 'in this view there is a "Save relations" button' do
    page.find('#coreon-concept-map .save-map').should have_content("Save")
  end

  step 'I drag concept "pipeline transport" on the "destination of transport" concept' do
    drop = find(".concept-node", text: "intra-EU transport")
    find(".concept-node", text: "pipeline transport").drag_to drop
  end

  step 'I see concept "pipeline transport" connected with a thick line with concept "destination of transport"' do
    pending 'step not implemented'
  end

  step 'I see concept "pipeline transport" connected with a dotted line with concept "mode of transport"' do
    pending 'step not implemented'
  end

  step 'I click "Save relations"' do
    page.find('#coreon-concept-map .save-map').click
  end

  step 'I am not in edit mode' do
    pending 'step not implemented'
  end

  step 'I am in edit mode but save is disabled' do
    page.find('#coreon-concept-map .save-map').should be_disabled
  end

  step 'I see concept "pipeline transport" connected with concept "destination of transport"' do
    pending 'step not implemented'
  end

  step 'I see concept "pipeline transport" connected with concept "intra-EU transport"' do
    pipeline_transport_concept = get_concept_details @concept2
    pipeline_transport_concept['superconcept_ids'][0].should eq @concept1['id']
  end


  step 'I see concept "intra-EU transport" connected with concept "destination of transport"' do
    intra_EU__transport_concept = get_concept_details @concept1
    intra_EU__transport_concept['superconcept_ids'][0].should eq @superconcept1['id']
  end

  step 'I see concept "mode of transport" does not heave any subconcepts' do
    intra_EU__transport_concept = get_concept_details @superconcept2
    intra_EU__transport_concept['superconcept_ids'][0].should eq nil
  end

  step 'I click "Reset"' do
    page.find('#coreon-concept-map .reset-map').click
  end

  step 'I am in edit mode' do
    page.find('#coreon-concept-map .save-map').should be_disabled
  end

  step 'I see concept "destination of transport" connected with concept "intra-EU transport"' do
    destination_of_transport_concept = get_concept_details @superconcept1
    destination_of_transport_concept['subconcept_ids'][0].should eq @concept1['id']
  end

  step 'I see concept "mode of transport" connected with concept "pipeline transport"' do
    mode_of_transport_concept = get_concept_details @superconcept2
    mode_of_transport_concept['subconcept_ids'][0].should eq @concept2['id']
  end

  step 'I see concept "pipeline transport" has no connection with concept "destination of transport"' do
    destination_of_transport_concept = get_concept_details @superconcept1
    destination_of_transport_concept['subconcept_ids'][0].should_not eq @concept2['id']
    destination_of_transport_concept['superconcept_ids'][0].should_not eq @concept2['id']
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
     #page.find('#coreon-concept-map').should have_content("Concept Map")
#     page.find('#coreon-concept-map').have_content?("Concept Map")
#      page.find('#coreon-concept-map').should have_css('h3', :text => 'Concept Map')
#      page.find('#coreon-concept-map').should have_text('Concept Map')
#    sleep 2
    #page.find("#coreon-main").should have_content("Concept Map")
    #page.find('#coreon-concept-map').should have_content("Concept Map")
   #page.find("#coreon-modal .confirm").should have_content("delete 1 properties")
  end

  step 'I click the "Edit mode" button' do
    page.find('#coreon-concept-map .edit-map').click
    sleep 1
  end

  step 'I expanded tree' do
    find(".concept-node.placeholder").click
    sleep 1
    all(".concept-node.placeholder").each(&:click)
  end

end
