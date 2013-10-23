class Spinach::Features::UserTogglesOrientationOfConceptMap < Spinach::FeatureSteps
  include AuthSteps
  include Api::Graph::Factory
  include EdgesHelpers

  step 'a concept "handgun"' do
    @concept = create_concept_with_label "handgun"
  end

  step 'this concept is narrower than "weapon"' do
    @weapon ||= create_concept_with_label "weapon"
    link_narrower_to_broader @concept, @weapon
  end

  step 'I visit the single concept page for "handgun"' do
    visit "/#{@repository.id}/concepts/#{@concept['id']}"
  end

  step 'I should see "handgun" being selected in the concept map' do
    page.should have_css("#coreon-concept-map .concept-node.hit", text: "handgun")
  end

  step 'it should be connected to "weapon"' do
    page.should have_css(".concept-node", text: "weapon")
    @edges = collect_edges
    @edges.should include("weapon -> handgun")
  end

  def get_position(label)
    page.evaluate_script "$('.concept-node:contains(#{label})').position()"
  end

  step '"weapon" should be rendered left of "handgun"' do
    sleep 0.2
    weapon_position = get_position "weapon"
    handgun_position = get_position "handgun"
    weapon_position["left"].should < handgun_position["left"]
  end

  step 'I click "Toggle orientation"' do
    page.click_on "Toggle orientation"
  end

  step '"handgun" should still be selected' do
    page.should have_css("#coreon-concept-map .concept-node.hit", text: "handgun")
  end

  step '"weapon" should be rendered above "handgun"' do
    weapon_position = get_position "weapon"
    handgun_position = get_position "handgun"
    weapon_position["top"].should < handgun_position["top"]
  end
end
