# encoding: utf-8

class MaintainerConnectsConceptFromClipboard < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include SearchSteps
  include Api::Graph::Factory

  step 'a concept with label "panopticum" exists' do
    @concept = create_concept_with_label "panopticum"
  end

  step 'a concept with label "surveillance" exists' do
    @concept = create_concept_with_label "surveillance"
  end

  step 'I click the button "Add to clipboard"' do
    click_link("Add to clipboard")
  end

  step 'I drag the search result to the clipboard' do
    find(".search-results a.concept-label.ui-draggable").drag_to find("#coreon-clipboard ul")
  end

  step 'I click on the search result' do
    find(".search-results a.concept-label").click
  end

  step 'I search for "panopticum"' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "panopticum"
      find('input[type="submit"]').click
    end
  end

  step 'I search for "surveillance"' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "surveillance"
      find('input[type="submit"]').click
    end
  end

  step 'I click "Edit Concept"' do
    click_link_or_button "Edit concept"
  end

  step 'I drag the clipped concept to the subconcept dropzone' do
    find('#coreon-clipboard li a.concept-label.ui-draggable').drag_to find(".concept.edit .broader-and-narrower.ui-state-highlight .narrower")
  end

  step 'I drag the clipped concept to the superconcept dropzone' do
    find('#coreon-clipboard li a.concept-label.ui-draggable').drag_to find(".concept.edit .broader-and-narrower.ui-state-highlight .broader")
  end

  step 'I should see "panopticum" unsaved as narrower concept' do
    within ".concept.edit .broader-and-narrower.ui-state-dirty .narrower" do
      has_css("li .concept-label.pending", text: "panopticum")
    end
  end

  step 'I should see reset, cancel and save buttons' do
    within ".concept.edit .broader-and-narrower.ui-state-dirty" do
      has_css(".submit .reset")
      has_css(".submit .cancel")
      has_css(".submit .submit")
    end
  end

  step 'I click Save' do
    within ".concept.edit .broader-and-narrower.ui-state-dirty" do
      click_link_or_button "Save"
    end
  end

  step 'I click Cancel' do
    within ".concept.edit .broader-and-narrower.ui-state-dirty" do
      click_link_or_button "Cancel"
    end
  end

  step 'I click Reset' do
    within ".concept.edit .broader-and-narrower.ui-state-dirty" do
      click_link_or_button "Reset"
    end
  end

  step 'I debug' do
    binding.pry
  end
end
