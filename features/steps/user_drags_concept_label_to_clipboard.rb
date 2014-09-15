# encoding: utf-8
class UserDragsConceptLabelToClipboard < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include Factory


  step 'I visit the home page' do
    visit "/"
  end

  step 'a concept "panopticum" with super concept "surveillance" exists' do
    @surveillance = create_concept_with_label "surveillance"
    @panopticum = create_concept_with_label "panopticum", superconcept_ids:[@surveillance['id']]
  end

  step 'I search for "panopticum"' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "panopticum"
      find('input[type="submit"]').click
    end
    expect(page).to have_css('.concept-list-item a', text: 'panopticum')
  end

  step 'I should see two draggable elements' do
    page.should have_css('[data-drag-ident]')
    all('[data-drag-ident]').size.should == 2
  end

  step 'I drag the label of "panopticum" into the clipboard' do
    find("[data-drag-ident='#{@panopticum["id"]}']").drag_to page.find("#coreon-clipboard ul")
  end

  step 'I drag the title of the concept to the clipboard' do
    find("h2.label").drag_to page.find("#coreon-clipboard ul")
  end

  step 'I should see "panopticum" in clipboard' do
    page.should have_css('#coreon-clipboard li', text: "panopticum")
  end

  step 'I should see "surveillance" in clipboard' do
    page.should have_css('#coreon-clipboard li', text: "surveillance")
  end

  step 'I still should see only one "surveillance" in clipboard' do
    all('#coreon-clipboard li', text: "surveillance").size.should == 1
  end

  step 'I click on the "surveillance" concept' do
    find(".concept-label", text: "surveillance").click
  end

end
