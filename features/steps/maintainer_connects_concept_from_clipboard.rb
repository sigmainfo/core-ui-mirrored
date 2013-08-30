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

  step 'I click "Edit concept"' do
    click_link_or_button "Edit concept"
  end

  step 'I click "Edit concept connections"' do
    click_link_or_button "Edit concept connections"
  end

  step 'I drag the clipped concept to the subconcept dropzone' do
    drop = find(".concept.edit .broader-and-narrower .narrower.ui-droppable")
    find('#coreon-clipboard li a.concept-label.ui-draggable').drag_to drop
  end

  step 'I drag the clipped concept to the superconcept dropzone' do
    drop = find(".concept.edit .broader-and-narrower .broader.ui-droppable")
    find('#coreon-clipboard li a.concept-label.ui-draggable').drag_to drop
  end

  step 'I should see "panopticum" unsaved as narrower concept' do
    within ".concept.edit .broader-and-narrower .narrower.ui-droppable" do
      find "li .concept-label", text: "panopticum"
    end
  end

  step 'I should see "panopticum" unsaved as broader concept' do
    within ".concept.edit .broader-and-narrower .broader.ui-droppable" do
      find "li .concept-label", text: "panopticum"
    end
  end

  step 'I should see reset, cancel and save buttons' do
    within ".concept.edit .broader-and-narrower form.active" do
      find(".submit .reset")
      find(".submit .cancel")
      find(".submit [type=submit]")
    end
  end

  step 'the concept should have a new narrower connection' do
    within ".concept.edit .broader-and-narrower .narrower.static" do
      find "li .concept-label", text: "panopticum"
    end
  end

  step 'the concept should have a new broader connection' do
    within ".concept.edit .broader-and-narrower .broader.static" do
      find "li .concept-label", text: "panopticum"
    end
  end

  step 'I should not see any unsaved concepts' do
    page.should have_no_css(".broader-and-narrower li .concept-label", text: "panopticum")
  end

  step 'I should not see drop zones' do
    page.should have_css(".broader-and-narrower form.static")
    page.should have_no_css(".broader-and-narrower form.active")
  end

  step 'I click Save' do
    within ".concept.edit .broader-and-narrower form.active" do
      click_link_or_button "Save"
    end
  end

  step 'I click Cancel' do
    within ".concept.edit .broader-and-narrower form.active" do
      click_link_or_button "Cancel"
    end
  end

  step 'I click Reset' do
    within ".concept.edit .broader-and-narrower form.active" do
      click_link_or_button "Reset"
    end
  end

  step 'I debug' do
    binding.pry
  end
end
