# encoding: utf-8

class MaintainerDisconnectsBroaderAndNarrowerConcepts < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include SearchSteps
  include Api::Graph::Factory

  step 'a concept with label "panopticum", superconcept "surveillance" and subconcept "camera" exists' do
    @superConcept = create_concept_with_label "surveillance"
    @subConcept = create_concept_with_label "camera"
    @concept = create_concept_with_label "panopticum",
      super_concept_ids: [@superConcept['_id']],
      sub_concept_ids: [@subConcept['_id']]
  end

  step 'I am on the show concept page of "panopticum"' do
    visit "/#{@repository.id}/concepts/#{@concept['_id']}"
  end

  step 'I click "Edit concept"' do
    click_link_or_button "Edit concept"
  end

  step 'I click "Edit broader & narrower concepts"' do
    click_link_or_button "Edit broader & narrower concepts"
  end

  step 'I drag "surveillance" out of the super concept list' do
    drop = find(".concept.edit .broader-and-narrower .list.ui-droppable")
    find('.broader.ui-droppable li a.concept-label.ui-draggable').drag_to drop
  end

  step 'I drag "camera" out of the sub concept list' do
    drop = find(".concept.edit .broader-and-narrower .list.ui-droppable")
    find('.narrower.ui-droppable li a.concept-label.ui-draggable').drag_to drop
  end

  step 'I drag "camera" back to the sub concept list' do
    drop = find(".concept.edit .broader-and-narrower .narrower.ui-droppable ul")
    find("#coreon-clipboard li .concept-label", text: "camera").drag_to drop
  end

  step 'I drag "camera" to the super concept list' do
    drop = find(".concept.edit .broader-and-narrower .broader.ui-droppable ul")
    find("#coreon-clipboard li .concept-label", text: "camera").drag_to drop
  end

  step 'I drag "camera" out of the super concept list' do
    drop = find(".concept.edit .broader-and-narrower .list.ui-droppable")
    find('.broader.ui-droppable li a.concept-label.ui-draggable', text: "camera").drag_to drop
  end

  step 'I should see no super concept anymore' do
    page.should have_no_css('.broader.ui-droppable li')
  end

  step 'I should see no sub concept anymore' do
    page.should have_no_css('.narrower.ui-droppable li')
  end

  step 'I should see no broader and narrower concepts anymore' do
    page.should have_no_css('.broader li .concept-label')
    page.should have_no_css('.narrower li .concept-label')
  end

  step 'I should see "camera" as narrower concept' do
    within ".concept.edit .broader-and-narrower .narrower.ui-droppable" do
      find "li .concept-label", text: "camera"
    end
  end

  step 'I should see "camera" as broader concept' do
    within ".concept.edit .broader-and-narrower .broader.ui-droppable" do
      find "li .concept-label", text: "camera"
    end
  end

  step 'I should see "surveillance" as broader concept' do
    within ".concept.edit .broader-and-narrower .broader.ui-droppable" do
      find "li .concept-label", text: "surveillance"
    end
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

  step 'still see "surveillance" as broader and "camera" as narrower concept' do
      find "form.static .broader li .concept-label", text: "surveillance"
      find "form.static .narrower li .concept-label", text: "camera"
  end

  step 'I should not be in edit mode anymore' do
    page.should have_css(".broader-and-narrower form.static")
    page.should have_no_css(".broader-and-narrower form.active")
  end

  step 'I drag "camera" to the clipboard' do
    find(".narrower.ui-droppable .concept-label", text: "camera").drag_to find("#coreon-clipboard .ui-droppable")
  end
end
