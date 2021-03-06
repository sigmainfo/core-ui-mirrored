# encoding: utf-8

class MaintainerConnectsConceptFromClipboard < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include SearchSteps
  include Factory

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
    find(".concept-list a.concept-label.ui-draggable").drag_to find("#coreon-clipboard ul")
  end

  step 'I click on the search result' do
    sleep 0.5
    expect(page).to have_css('.concept-list .concept-list-item a.concept-label')
    find(".concept-list a.concept-label").click
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

  step 'I click "Edit connections"' do
    click_link_or_button "Edit connections"
  end

  step 'I drag the clipped concept to the subconcept dropzone' do
    drop = find(".concept.edit .broader-and-narrower .narrower ul")
    find('#coreon-clipboard li a.concept-label.ui-draggable').drag_to drop
  end

  step 'I drag the clipped concept to the superconcept dropzone' do
    drop = find(".concept.edit .broader-and-narrower .broader ul")
    find('#coreon-clipboard li a.concept-label.ui-draggable').drag_to drop
  end

  step 'I should see "panopticum" unsaved as narrower concept' do
    within ".concept.edit .broader-and-narrower .narrower" do
      find "li .concept-label", text: "panopticum"
    end
  end

  step 'I should see "panopticum" unsaved as broader concept' do
    within ".concept.edit .broader-and-narrower .broader" do
      find "li .concept-label", text: "panopticum"
    end
  end

  step 'I should see reset, cancel and save buttons' do
    within ".concept.edit .broader-and-narrower form" do
      find(".submit .reset")
      find(".submit .cancel")
      find(".submit [type=submit]")
    end
  end

  step 'the concept should have a new narrower connection' do
    within ".concept.edit .broader-and-narrower .narrower" do
      find "li .concept-label", text: "panopticum"
    end
  end

  step 'the concept should have a new broader connection' do
    within ".concept.edit .broader-and-narrower .broader" do
      find "li .concept-label", text: "panopticum"
    end
  end

  step 'I should not see any unsaved concepts' do
    page.should have_no_css(".broader-and-narrower li .concept-label", text: "panopticum")
  end

  step 'I should not see drop zones' do
    page.should have_no_css(".broader-and-narrower form")
  end

  step 'I click Save' do
    within ".concept.edit .broader-and-narrower form" do
      click_link_or_button "Save"
    end
  end

  step 'I click Cancel' do
    within ".concept.edit .broader-and-narrower form" do
      click_link_or_button "Cancel"
    end
  end

  step 'I click Reset' do
    within ".concept.edit .broader-and-narrower form" do
      click_link_or_button "Reset"
    end
  end
end
