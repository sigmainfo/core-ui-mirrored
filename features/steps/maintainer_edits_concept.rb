# encoding: utf-8
class MaintainerEditsConcept < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps
  include Api::Graph::Factory

  step 'I have maintainer privileges' do
    page.execute_script 'Coreon.application.session.ability.set("role", "maintainer");'
  end

  step 'a concept with property "label" of "handgun" exists' do
    @concept = create_concept properties: [{key: 'label', value: 'handgun'}]
  end

  step 'I visit the page of this concept' do
    visit "/concepts/#{@concept["_id"]}"
  end

  step 'I click "Edit concept"' do
    click_link "Edit concept"
  end

  step 'I should see edit buttons' do
    page.should have_css(".concept .properties .edit-properties")
  end

  step 'I should not see edit buttons' do
    page.should have_no_css(".concept .properties .edit-properties")
  end
end
