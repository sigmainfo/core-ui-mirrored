# encoding: utf-8
class MaintainerCreatesNarrowerConcept < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include NavigationSteps
  include Api::Graph::Factory


  step 'a concept with label "panopticum" exists' do
    @concept = create_concept_with_label "panopticum"
  end

  step 'I should see a button "Add narrower concept"' do
    page.should have_link("Add narrower concept")
  end

  step 'I click "Add narrower concept"' do
    click_link("Add narrower concept")
  end

  step 'I should be on the new concept page' do
    page.current_path.should == "/#{current_repository.id}/concepts/new/broader/#{@concept['id']}"
  end

  step 'I should see "panopticum" within the list of broader concepts' do
    page.should have_css(".broader-and-narrower .broader li", text: "panopticum")
  end

  step 'I click "Create concept"' do
    click_button "Create concept"
  end

  step 'I should be on the show concept page' do
    page.should have_no_css(".concept.new")
    page.current_path.should =~ %r|^/#{current_repository.id}/concepts/[0-9a-f]{24}$|
    @id = current_path.split("/").last
  end

  step 'I should see the id of the newly created concept within the title' do
    page.should have_css(".label", text: @id)
  end

  step 'I click on "panopticum"' do
    click_link "panopticum"
  end

  step 'I should be on the show concept page of "panopticum"' do
    current_path.should == "/#{current_repository.id}/concepts/#{@concept['id']}"
  end

  step 'I should see the id of the newly created concept within the list of narrower concepts' do
    page.should have_css(".broader-and-narrower .narrower li", text: @id)
  end
end
