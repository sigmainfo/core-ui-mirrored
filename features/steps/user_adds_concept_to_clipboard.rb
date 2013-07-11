# encoding: utf-8

class UserAddsConceptToClipboard < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include Api::Graph::Factory

  step 'a concept with label "panopticum" exists' do
    @concept = create_concept_with_label "panopticum"
  end

  step 'I should see a clipboard' do
    page.should have_css("#coreon-clipboard")
  end

  step 'the clipboard should be empty' do
    page.find("#coreon-clipboard").should have_no_css("ul li")
  end

  step 'I should see a button "Add to clipboard"' do
    page.should have_css("#coreon-main .concept .concept-to-clipboard", text: "Add to clipboard")
  end

  step 'I click the button "Add to clipboard"' do
    click_link("Add to clipboard")
  end

  step 'I should see a link to the concept in the clipboard' do
    page.should have_css("#coreon-clipboard li > a", text: "panopticum")
  end
end
