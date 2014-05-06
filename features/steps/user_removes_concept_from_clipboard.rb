# encoding: utf-8

class UserRemovesConceptFromClipboard < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include SearchSteps
  include Api::Graph::Factory

  step 'a concept with label "panopticum" exists' do
    @concept = create_concept_with_label "panopticum"
  end

  step 'the clipboard should be empty' do
    page.find("#coreon-clipboard").should have_no_css("ul li")
  end

  step 'I should see a button "Remove from clipboard"' do
    page.should have_css("#coreon-main .concept .actions a", text: "Remove from clipboard")
  end

  step 'I click the button "Add to clipboard"' do
    click_link("Add to clipboard")
  end

  step 'I click the button "Remove from clipboard"' do
    click_link("Remove from clipboard")
  end

  step 'I should see one clipboard entry "panopticum"' do
    page.should have_css("#coreon-clipboard li > a", text: "panopticum")
  end
end
