class Spinach::Features::MaintainerDeletesConcept < Spinach::FeatureSteps

  include AuthSteps
  include EditSteps
  include Api::Graph::Factory

  step 'a concept with an English term "beaver hat" exists' do
    @concept = create_concept terms: [
      { lang: "en", value: "beaver hat" }
    ]
  end

  step 'I am on the show concept page of "beaver hat"' do
    visit "/#{current_repository.id}/concepts/#{@concept['id']}"
  end

  step 'I click "Delete concept"' do
    click_link "Delete concept"
  end

  step 'I should see a confirmation dialog "This concept including all terms will be deleted permanently."' do
    page.should have_css(".confirm .message", text: "This concept including all terms will be deleted permanently!")
  end


  step 'I should still be on the show concept page' do
    page.current_path.should == "/#{current_repository.id}/concepts/#{@concept['id']}"
  end

  step 'I should be on the repository root page' do
    page.should have_css(".repository h2.name")
    page.current_path.should == "/#{current_repository.id}"
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
    within ".concept-list" do
      page.should have_no_content("beaver hat")
    end
  end

  step '"beaver hat" is a subconcept of "hat"' do
    @superconcept = create_concept terms: [{lang: "en", value: "hat"}]
    link_narrower_to_broader @concept, @superconcept
  end

  step 'I navigate to the show concept of "hat"' do
    page.execute_script "Backbone.history.navigate('#{current_repository.id}/concepts/#{@superconcept['id']}', {trigger: true})"
    page.should have_css("h2.label", text: "hat")
  end

  step 'I should see no narrower concepts for "hat"' do
    within "section.broader-and-narrower" do
      page.should have_no_css(".narrower li")
    end
  end
end
