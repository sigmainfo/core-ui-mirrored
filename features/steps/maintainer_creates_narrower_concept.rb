# encoding: utf-8
class MaintainerCreatesNarrowerConcept < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include Factory
  include Resources
  include Selectors

  step 'the repository defines an empty blueprint for concepts' do
    @blueprint = blueprint(:concept)
    @blueprint['clear'].delete
  end

  step 'the repository defines an empty blueprint for terms' do
    @blueprint = blueprint(:term)
    @blueprint['clear'].delete
  end

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
    broader = find(".broader-and-narrower .broader li", text: "panopticum")
    expect(broader).to be_visible
  end

  step 'I fill the term value with "test"' do
    fill_in "Value", with: "test"
  end

  step 'I fill "Language" of term with "English"' do
    fieldset = page.find ".term > .lang"
    select_from_coreon_dropdown fieldset, 'English'
  end

  step 'I click "Create concept"' do
    click_button "Create concept"
  end

  step 'I should be on the show concept page' do
    page.should have_no_css(".concept.new")
    page.current_path.should =~ %r|^/#{current_repository.id}/concepts/[0-9a-f]{24}$|
    @id = current_path.split("/").last
  end

  step 'I should see the newly created concept with the title "test"' do
    page.should have_css(".label", text: 'test')
  end

  step 'I click on "panopticum"' do
    click_link "panopticum"
  end

  step 'I should be on the show concept page of "panopticum"' do
    current_path.should == "/#{current_repository.id}/concepts/#{@concept['id']}"
  end

  step 'I should see "test" within the list of narrower concepts' do
    page.should have_css(".broader-and-narrower .narrower li", text: 'test')
  end
end
