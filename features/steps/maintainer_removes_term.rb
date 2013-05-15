class Spinach::Features::MaintainerRemovesTerm < Spinach::FeatureSteps

  include AuthSteps
  include Api::Graph::Factory
  include EditSteps

  step 'a concept with an English term "beaver hat" exists' do
    @concept = create_concept terms: [
      { lang: "en", value: "beaver hat" }
    ]
  end

  step 'I am on the show concept page of this concept' do
    page.execute_script "Backbone.history.navigate('concepts/#{@concept['_id']}', { trigger: true })"
  end

  step 'I click "Remove term" within term "beaver hat"' do
    page.find(".term .value", text: "beaver hat").find(:xpath, './parent::*').find(".edit a", text: "Remove term").click
  end

  step 'I should see a confirmation dialog "This term will be deleted permanently."' do
    page.should have_css(".confirm .message", text: "This term will be deleted permanently.")
  end

  step 'I should still see the English term "beaver hat"' do
    page.should have_css(".term .value", text: "beaver hat")
  end

  step 'I should see a message \'Successfully deleted term "beaver hat".\'' do
    page.should have_css(".notification", text: 'Successfully deleted term "beaver hat".')
  end

  step 'I should not see "beaver hat"' do
    within ".concept" do
      page.should have_no_content("beaver hat")
    end
  end
end
