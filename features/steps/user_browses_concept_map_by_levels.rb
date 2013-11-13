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
      page.should have_css('.concept-node.hit', text: 'ball')
      page.should have_css('.concept-node.hit', text: '8-ball')
      page.should have_css('.concept-node.hit', text: 'nine ball')
    end
  end

  def collect_node_levels
    tops_and_labels = page.evaluate_script <<-JS
      $("#coreon-concept-map .concept-node").map( function() {
        return [$(this).position().top, $(this).find("tspan").text()]
      }).get();
    JS
    levels = tops_and_labels.each_slice(2).to_a.group_by { |node| (node.shift / 100).round }
    levels.each_value { |val| val.flatten!.delete_if &:empty? }.values
  end

  step 'I should see "billiards" at level 1' do
    @levels = collect_node_levels
    @levels[1].should == ["billiards"]
  end

  step 'I should see "equipment", "types" on level 2' do
    @levels[2].sort.should == ["equipment", "types"]
  end

  step 'I should see "ball", "pool" at level 3' do
    @levels[3].sort.should == ["ball", "pool"]
  end

  step 'I should see "8-ball", "nine ball" at level 4' do
    @levels[4].sort.should == ["8-ball", "nine ball"]
  end

  step '"billiards", "equipment", "types", "pool" should be rendered as parents of hit' do
    %w|billiards equipment types pool|.each do |label|
      page.should have_css("#coreon-concept-map .concept-node.parent-of-hit", text: label)
    end
  end

  step 'I click on "Games" within the concept map' do
    page.find("#coreon-concept-map .concept-node", text: "Games").find("a").click
  end

  step 'I should be on the repository root page' do
    page.should have_css(".repository.show h2.name", text: "Games")
    page.current_path.should == "/#{@repository.id}"
  end
end
