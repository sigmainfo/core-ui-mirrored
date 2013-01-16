class UserBrowsesConceptGraph < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps
  include Api::Graph::Factory

  def collect_edges(count)
    @edges = []
    (0...count).each do |i|
      edge = page.evaluate_script(%Q|$("#coreon-concept-map .concept-edge").get(#{i}).__data__.source.concept.label()|)
      edge << " -> "
      edge << page.evaluate_script(%Q|$("#coreon-concept-map .concept-edge").get(#{i}).__data__.target.concept.label()|)
      @edges.push edge
    end
    @edges
  end

  Given 'a concept "handgun"' do
    @concept = create_concept_with_label "handgun"
  end

  And 'this concept is narrower than "weapon"' do
    @weapon ||= create_concept_with_label "weapon"
    link_narrower_to_broader @concept, @weapon
  end

  And 'this concept is broader than "pistol", "revolver"' do
    @pistol = create_concept_with_label "pistol"
    link_narrower_to_broader @pistol, @concept
    @revolver = create_concept_with_label "revolver"
    link_narrower_to_broader @revolver, @concept
  end

  And 'given a concept "long gun"' do
    @concept = create_concept_with_label "long gun"
  end

  And 'this concept is broader than "rifle"' do
    @rifle = create_concept_with_label "rifle"
    link_narrower_to_broader @rifle, @concept
  end

  When 'I enter the application' do
    visit "/"
  end

  Then 'I should see the widget "Concept Map"' do
    page.should have_css(".widget h4", text: "Concept Map")
  end

  And 'it should be empty' do
    page.all("#coreon-concept-map .concept-node").count.should == 0
  end

  And 'select "handgun" from the result list' do
    page.find(".search-results-concepts .concept-label", text: "handgun").click
  end

  Then 'I shoud see "weapon", "handgun", "long gun", "pistol", and "revolver" displayed in the concept map' do
    ["weapon", "handgun", "long gun", "pistol", "revolver"].each do |label|
      page.should have_css("#coreon-concept-map .concept-node", text: label)
    end
  end

  And '"handgun" should be marked as being selected' do
    page.should have_css("#coreon-concept-map .concept-node.hit", text: "handgun")
  end

  And '"weapon" should be connected to "handgun"' do
    collect_edges 4
    @edges.should include("weapon -> handgun")
  end

  And '"weapon" should be connected to "long gun"' do
    @edges.should include("weapon -> long gun")
  end

  And '"handgun" should be connected to "pistol"' do
    @edges.should include("handgun -> pistol")
  end

  And '"handgun" should be connected to "revolver"' do
    @edges.should include("handgun -> revolver")
  end

  But 'I should not see "rifle"' do
    page.should have_no_css("#coreon-concept-map .concept-node", text: "rifle")
  end

  When 'I click to toggle the children of "long gun"' do
    page.find("#coreon-concept-map .concept-node", text: "long gun").find(".toggle-children").click
  end
  
  When 'I click to toggle the children of "weapon"' do
    page.find("#coreon-concept-map .concept-node", text: "weapon").find(".toggle-children").click
  end

  Then 'I should see "rifle"' do
    page.should have_css("#coreon-concept-map .concept-node", text: "rifle")
  end

  And '"long gun" should be connected to "rifle"' do
    collect_edges 5
    @edges.should include("long gun -> rifle")
  end

  Then '"weapon" should be the only node left' do
    nodes = page.all("#coreon-concept-map .concept-node")
    nodes.should have(1).item
    nodes.first.text.should == "weapon"
  end
end
