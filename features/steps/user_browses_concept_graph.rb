# encoding: utf-8

class UserBrowsesConceptGraph < Spinach::FeatureSteps

  include AuthSteps
  include SearchSteps
  include Api::Graph::Factory
  include EdgesHelpers

  step 'a concept "handgun"' do
    @concept = create_concept_with_label "handgun"
  end

  step 'this concept is narrower than "weapon"' do
    @weapon ||= create_concept_with_label "weapon"
    link_narrower_to_broader @concept, @weapon
  end

  step '"weapon" is narrower than "tool"' do
    @tool ||= create_concept_with_label "tool"
    link_narrower_to_broader @weapon, @tool
  end

  step 'I enter the application' do
    visit "/"
  end

  step 'I should see the widget "Concept Map"' do
    page.should have_css(".widget h3", text: "Concept Map")
  end

  step 'it should show the repository root node only' do
    page.should have_css("#coreon-concept-map .concept-node.repository-root")
    page.all("#coreon-concept-map .concept-node:not(.placeholder)").count.should == 1
  end

  step 'select "handgun" from the result list' do
    page.find(".concept-list .concept-label", text: "handgun").click
  end

  step 'I should see "handgun" displayed in the concept map' do
    page.should have_css("#coreon-concept-map .concept-node", text: "handgun")
  end

  step 'I should see a node "weapon"' do
    # use Nokogiri directly to fix matching of SVG nodes
    Nokogiri::HTML(page.body).css(".concept-node text").map(&:text).should include("weapon")
  end

  step 'only "handgun" should be marked as being selected' do
    page.should have_css("#coreon-concept-map .concept-node.hit", text: "handgun")
    page.all("#coreon-concept-map .concept-node.hit").size.should == 1
  end

  step '"weapon" should be connected to "handgun"' do
    @edges = collect_edges
    @edges.should include("weapon -> handgun")
  end

  step 'I should see a node "tool"' do
    # use Nokogiri directly to fix matching of SVG nodes
    Nokogiri::HTML(page.body).css(".concept-node text").map(&:text).should include("tool")
  end

  step '"tool" should be connected to "weapon"' do
    @edges.should include("tool -> weapon")
  end

  step 'the repository root node should be connected to "tool"' do
    @edges.should include("Nobody's Repository -> tool")
  end

  step 'a concept "hand"' do
    @concept = create_concept_with_label "hand"
  end

  step 'a concept "handkerchief"' do
    @concept = create_concept_with_label "handkerchief"
  end

  step 'I search for "hand"' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "hand"
      find('input[type="submit"]').click
    end
  end

  step 'I should see a node "hand"' do
    page.should have_css("#coreon-concept-map .concept-node", text: "hand")
  end

  step 'I should see a node "handkerchief"' do
    page.should have_css("#coreon-concept-map .concept-node", text: "handkerchief")
  end

  step 'all nodes should be classified as hits' do
    page.all("#coreon-concept-map .concept-node.hit").size.should == 3
  end

  step 'I click on "Zoom in"' do
    sleep 0.5
    @orig = evaluate_script "$('.concept-map .concept-node').get(0).getBoundingClientRect()"
    page.find("#coreon-concept-map a", text: "Zoom in").click
  end

  step '"handgun" should be bigger' do
   box = evaluate_script "$('.concept-map .concept-node').get(0).getBoundingClientRect()"
   box["height"].should > @orig["height"]
  end

  step 'I click on "Zoom out"' do
    page.find("#coreon-concept-map a", text: "Zoom out").click
  end

  step '"handgun" should have the original size again' do
    box = evaluate_script "$('.concept-map .concept-node').get(0).getBoundingClientRect()"
    box["height"].should == @orig["height"]
  end
end
