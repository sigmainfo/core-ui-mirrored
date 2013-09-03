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

  step 'I click "Edit concept connections"' do
    click_link_or_button "Edit concept connections"
  end

  step 'I drag "surveillance" out of the super concept list' do
    drop = find(".concept.edit .broader-and-narrower .list.ui-droppable")
    find('.broader.ui-droppable li a.concept-label.ui-draggable').drag_to drop
  end

  step 'I drag "camera" out of the sub concept list' do
    drop = find(".concept.edit .broader-and-narrower .list.ui-droppable")
    find('.narrower.ui-droppable li a.concept-label.ui-draggable').drag_to drop
  end

  step 'I should see no super concept anymore' do
    page.should have_no_css('.broader.ui-droppable li')
  end

  step 'I should see no sub concept anymore' do
    page.should have_no_css('.narrower.ui-droppable li')
  end
end
