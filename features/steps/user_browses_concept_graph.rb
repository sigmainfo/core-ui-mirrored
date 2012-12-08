class UserBrowsesConceptGraph < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps
  include Api::Graph::Factory

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
    pending 'step not implemented'
  end

  And '"weapon" should be connected to "long gun"' do
    pending 'step not implemented'
  end

  And '"handgun" should be connected to "pistol"' do
    pending 'step not implemented'
  end

  And '"handgun" should be connected to "revolver"' do
    pending 'step not implemented'
  end

  But 'I should not see "rifle"' do
    pending 'step not implemented'
  end

  When 'I click to toggle the children of "long gun"' do
    pending 'step not implemented'
  end

  Then 'I should see "rifle"' do
    pending 'step not implemented'
  end

  And '"rifle" should be connected to "handgun"' do
    pending 'step not implemented'
  end
end
