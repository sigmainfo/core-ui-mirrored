# encoding: utf-8

class UserAddsConceptToClipboard < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include SearchSteps
  include Factory

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

  step 'the clip should not be highlighted' do
    page.should have_no_css("#coreon-clipboard li > a.hit", text: "panopticum")
  end

  step 'the clip should be highlighted as hit' do
    page.should have_css('#coreon-clipboard li > a.hit', text: 'panopticum')
  end

  step 'I should see a button "Clear" as clipboard action' do
    page.should have_css("#coreon-clipboard .actions .clear", text: "Clear")
  end

  step 'I click the button "Clear"' do
    click_link("Clear")
  end
end
