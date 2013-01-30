class UserBrowsesConceptGraph < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps
  include Api::Graph::Factory

  def collect_edges(count)
    @edges = []
    (0...count).each do |i|
      edge = page.evaluate_script(%Q|$("#coreon-concept-map .concept-edge").get(#{i}).__data__.source.concept.get("label")|)
      edge << " -> "
      edge << page.evaluate_script(%Q|$("#coreon-concept-map .concept-edge").get(#{i}).__data__.target.concept.get("label")|)
      @edges.push edge
    end
    @edges
  end

  step 'a concept "handgun"' do
    @concept = create_concept_with_label "handgun"
  end

  step 'this concept is narrower than "weapon"' do
    @weapon ||= create_concept_with_label "weapon"
    link_narrower_to_broader @concept, @weapon
  end

  step 'this concept is broader than "pistol", "revolver"' do
    @pistol = create_concept_with_label "pistol"
    link_narrower_to_broader @pistol, @concept
    @revolver = create_concept_with_label "revolver"
    link_narrower_to_broader @revolver, @concept
  end

  step 'given a concept "long gun"' do
    @concept = create_concept_with_label "long gun"
  end

  step 'this concept is broader than "rifle"' do
    @rifle = create_concept_with_label "rifle"
    link_narrower_to_broader @rifle, @concept
  end

  step '"weapon", "pen" are narrower than "tool"' do
    @tool ||= create_concept_with_label "tool"
    @pen  ||= create_concept_with_label "pen"
    link_narrower_to_broader @weapon, @tool
    link_narrower_to_broader @pen, @tool
  end

  step 'I enter the application' do
    visit "/"
  end

  step 'I should see the widget "Concept Map"' do
    page.should have_css(".widget h4", text: "Concept Map")
  end

  step 'it should be empty' do
    page.all("#coreon-concept-map .concept-node").count.should == 0
  end

  step 'select "handgun" from the result list' do
    page.find(".search-results-concepts .concept-label", text: "handgun").click
  end

  step 'I shoud see "handgun" displayed in the concept map' do
    page.should have_css("#coreon-concept-map .concept-node", text: "handgun")
  end
  
  step 'I should see nodes for "pistol" and "revolver"' do
    ["pistol", "revolver"].each do |label|
      page.should have_css("#coreon-concept-map .concept-node", text: label)
    end
  end
  
  step 'I should see a node "weapon"' do
    page.should have_css("#coreon-concept-map .concept-node", text: "weapon")
  end

  step '"handgun" should be marked as being selected' do
    page.should have_css("#coreon-concept-map .concept-node.hit", text: "handgun")
  end

  step '"weapon" should be connected to "handgun"' do
    collect_edges 4
    @edges.should include("weapon -> handgun")
  end

  step '"weapon" should be connected to "long gun"' do
    @edges.should include("weapon -> long gun")
  end

  step '"handgun" should be connected to "pistol"' do
    @edges.should include("handgun -> pistol")
  end

  step '"handgun" should be connected to "revolver"' do
    @edges.should include("handgun -> revolver")
  end

  step 'I should not see "rifle"' do
    page.should have_no_css("#coreon-concept-map .concept-node", text: "rifle")
  end

  step 'I click to toggle the children of "long gun"' do
    page.find("#coreon-concept-map .concept-node", text: "long gun").find(".toggle-children").click
  end
  
  step 'I click to toggle the children of "weapon"' do
    page.find("#coreon-concept-map .concept-node", text: "weapon").find(".toggle-children").click
  end

  step 'I should see "rifle"' do
    page.should have_css("#coreon-concept-map .concept-node", text: "rifle")
  end

  step '"long gun" should be connected to "rifle"' do
    collect_edges 5
    @edges.should include("long gun -> rifle")
  end

  step '"weapon" should be the only node left' do
    nodes = page.all("#coreon-concept-map .concept-node")
    nodes.should have(1).item
    nodes.first.text.should == "weapon"
  end

  step 'there should be no more connections' do
    page.should have_no_css("#coreon-concept-map .concept-edge")
  end

  step 'I click to toggle the parents of "weapon"' do
    page.find("#coreon-concept-map .concept-node", text: "weapon").find(".toggle-parents").click
  end

  step 'I should see "tool"' do
    page.should have_css("#coreon-concept-map .concept-node", text: "tool")
  end

  step 'I should see "pen"' do
    page.should have_css("#coreon-concept-map .concept-node", text: "pen")
  end

  step '"tool" should be connected to "weapon"' do
    collect_edges 1
    @edges.should include("tool -> weapon")
  end
end
