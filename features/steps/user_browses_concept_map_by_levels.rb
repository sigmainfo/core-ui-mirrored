class Spinach::Features::UserBrowsesConceptMapByLevels < Spinach::FeatureSteps

  include AuthSteps
  include Api::Graph::Factory

  step 'I am browsing a repository called "Games"' do
    @repository.update_attributes name: "Games"
  end

  step 'a top level concept "billiards" exists' do
    @billiards = create_concept_with_label "billiards"
  end

  step '"billiards" has a narrower concept "equipment"' do
    @equipment = create_concept_with_label "equipment", superconcept_ids: [ @billiards["id"] ]
  end

  step '"equipment" has narrower concepts "ball", "cue", "table"' do
    @ball = create_concept_with_label "ball", superconcept_ids: [ @equipment["id"] ]
    @cue = create_concept_with_label "cue", superconcept_ids: [ @equipment["id"] ]
    @table = create_concept_with_label "table", superconcept_ids: [ @equipment["id"] ]
  end

  step '"billiards" has a narrower concept "types"' do
    @types = create_concept_with_label "types", superconcept_ids: [ @billiards["id"] ]
  end

  step '"types" has a narrower concept "pool"' do
    @pool = create_concept_with_label "pool", superconcept_ids: [ @types["id"] ]
  end

  step '"pool" has narrower concepts "8-ball", "nine ball"' do
    @eight_ball = create_concept_with_label "8-ball", superconcept_ids: [ @pool["id"] ]
    @nine_ball = create_concept_with_label "nine ball", superconcept_ids: [ @pool["id"] ]
  end

  step 'I visit the repository root page' do
    visit "/#{@repository.id}"
  end

  step 'I should see a repository root node "Games"' do
    within "#coreon-concept-map" do
      page.should have_css(".repository-root", text: "Games")
    end
  end

  step 'I do a search for "ball"' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "ball"
      find('input[type="submit"]').click
    end
  end

  step 'I should see hits "ball", "8-ball", "nine ball" in the concept map' do
    within "#coreon-concept-map" do
      page.should have_css(".concept-node.hit")
      hits = page.all(".concept-node.hit text").map(&:text).sort
      hits.should == ["8-ball", "ball", "nine ball"]
    end
  end

  step 'I should see "billiards" at level 1' do
    pending 'step not implemented'
  end

  step 'I should see "equipment", "types" on level 2' do
    pending 'step not implemented'
  end

  step 'I should see "ball", "pool" at level 3' do
    pending 'step not implemented'
  end

  step 'I should see "8-ball", "nine ball" at level 4' do
    pending 'step not implemented'
  end

  step '"billiards", "equipment", "types", "pool" should be more prominent than "cue", "table"' do
    pending 'step not implemented'
  end
end
