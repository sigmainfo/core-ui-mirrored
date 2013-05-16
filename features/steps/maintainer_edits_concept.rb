# encoding: utf-8
class MaintainerEditsConcept < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps
  include SearchSteps
  include Api::Graph::Factory

  step 'a concept with property "label" of "handgun" exists' do
    @concept = create_concept properties: [{key: 'label', value: 'handgun'}]
  end

  step 'I visit the page of this concept' do
    visit "/concepts/#{@concept["_id"]}"
  end

  step 'I should see edit buttons' do
    page.should have_css(".concept .properties .edit-properties")
  end

  step 'I should not see edit buttons' do
    page.should have_no_css(".concept .properties .edit-properties")
  end
end
