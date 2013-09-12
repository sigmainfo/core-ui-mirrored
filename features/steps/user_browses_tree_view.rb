class Spinach::Features::UserBrowsesTreeView < Spinach::FeatureSteps

  include AuthSteps
  include Api::Graph::Factory

  step 'a concept "double action revolver with a swing out cylinder firing mechanism and barrel" exists' do
    @concept = create_concept_with_label "double action revolver with a swing out cylinder firing mechanism and barrel"
  end

  step 'this concept is narrower than "weapon"' do
    @weapon ||= create_concept_with_label "weapon"
    link_narrower_to_broader @concept, @weapon
  end

  step 'I visit the show concept page of this concept' do
    visit "/#{@repository.id}/concepts/#{@concept['id']}"
  end

  step 'I should see a multiline label representing the currently selected concept within the concept map' do
    within "#coreon-concept-map" do
      page.should have_css(".concept-node.hit a text",
        text: "double action revolver with a swing out cylinder firing mechanism and barrel"
      )
      page.all(".concept-node.hit a text tspan").count.should > 1
    end
  end
end
