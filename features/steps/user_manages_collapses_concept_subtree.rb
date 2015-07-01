class Spinach::Features::UserManagesCollapseConceptSubtree < Spinach::FeatureSteps

  include AuthSteps
  include Factory
  include Resources
  include Selectors

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

  step 'I expanded tree' do
    find(".concept-node.placeholder").click
    sleep 1
    all(".concept-node.placeholder").each(&:click)
   # binding.pry
  end

  step 'I click a concept node "mode of transport"' do
     ele = page.find(".concept-node", text: "mode of transport")
     ele.find('a').click
  end

  step 'It should not collapse the tree' do
     page.should have_css(".concept-node", :count => 5)
  end

  step 'I can see the opened sub concept node "pipeline transport" of concept node "mode of transport"' do
    page.should have_selector('.concept-node', text: 'pipeline transport')
    page.should have_selector('.concept-node', text: 'intra-EU transport')
  end

  step 'I can see the clicked node "mode of transport" details in right side widget' do
    widgetEle = page.find('#coreon-concepts')
    widgetEle.find('.concept-head h2.concept-label').should have_content("mode of transport")
  end


  step 'I expanded tree only first level' do
    find(".concept-node.placeholder").click
  end

  step 'I can not see second level nodes like "intra-EU transport" and "pipeline transport"' do
    page.should_not have_selector('.concept-node', text: 'pipeline transport')
    page.should have_no_selector('.concept-node', text: 'intra-EU transport')
  end

  step 'I click a concept node "intra-EU transport" and "pipeline transport" to expand' do
    sleep 1
    all(".concept-node.placeholder").each(&:click)
  end

  step 'I can see the "intra-EU transport" expanded' do
    page.should have_selector('.concept-node', text: 'intra-EU transport')
  end

  step 'I can see the "pipeline transport" expanded' do
    page.should have_selector('.concept-node', text: 'pipeline transport')
  end


  step 'I collapse a concept node "intra-EU transport"' do
    find(".negative-sign-"+@superconcept1['id']).click
  end

  step 'I can not see the "intra-EU transport" now because its collapsed' do
    #page.should_not have_selector('.concept-node', text: 'pipeline transport')
    page.should_not have_selector('.concept-node', text: 'intra-EU transport')
  end

  step 'I can see the "pipeline transport" expanded' do
    page.should have_selector('.concept-node', text: 'pipeline transport')
  end


  step 'the concept "destination of transport" and "mode of transport" has "common of transport" as a subconcept' do
    @concept3 = create_concept_with_label "common of transport",
                                          superconcept_ids: [@superconcept1['id'], @superconcept2['id']]
  end


  step 'I collapse a concept node "common of transport"' do
    find(".negative-sign-"+@superconcept1['id']).click
  end

  step 'I can not see the "common of transport" now because its collapsed' do
    page.should_not have_selector('.concept-node', text: 'common of transport')
  end

  step '"destination of transport" should have placeholder for collapsed node' do
    page.should have_selector('.concept-node.placeholder ', text: '2 more concepts for destination of transport')
  end

  step '"mode of transport" should have placeholder for collapsed node' do
    page.should have_selector('.sibling-node.placeholder ', text: '1 more concept for mode of transport')
  end

  step 'I expand "mode of transport" concept' do
    all(".sibling-node.placeholder").each(&:click)
  end

  step '"destination of transport" should not have any placeholder for collapsed node' do
    page.should_not have_content(text: '2 more concepts for destination of transport')
  end

  step '"mode of transport" should not have placeholder for multi sub node collapsed node' do
    page.should_not have_content('1 more concept for mode of transport')
  end

  step '"destination of transport" now have one concept only as a placeholder now' do
    page.should have_selector('.sibling-node.placeholder ', text: '1 more concept for destination of transport')
  end

  step "I change from portrait to landscape mode" do
    page.find('#coreon-concept-map .toggle-orientation').click
  end

  step "I change from landscape to portrait mode" do
    page.find('#coreon-concept-map .toggle-orientation').click
  end
end
