class Spinach::Features::MaintainerDeletesConcept < Spinach::FeatureSteps

  include AuthSteps
  include EditSteps
  include Api::Graph::Factory

  step 'a concept with an English term "beaver hat" exists' do
    @concept = create_concept terms: [
      { lang: "en", value: "beaver hat" }
    ]
  end

  step 'I am on the show concept page of this concept' do
    page.execute_script "Backbone.history.navigate('concepts/#{@concept['_id']}', { trigger: true })"
  end

  step 'I click "Delete concept"' do
    click_link "Delete concept"
  end

  step 'I should see a confirmation dialog "This concept including all terms will be deleted permanently."' do
    page.should have_css(".confirm .message", text: "This concept including all terms will be deleted permanently!")
  end


  step 'I should still be on the show concept page' do
    page.current_path.should == "/concepts/#{@concept['_id']}"
  end

  step 'I should be on the repository root page' do
    page.current_path.should == "/"
  end

  step 'I should see a message \'Successfully deleted concept "beaver hat".\'' do
    page.should have_css(".notification", text: 'Successfully deleted concept "beaver hat".')
  end

  step 'I search for "hat"' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "hat"
      find('input[type="submit"]').click
    end
  end

  step 'I should not see "beaver hat"' do
    within ".search-results-concepts" do
      page.should have_no_content("beaver hat")
    end
  end
end
