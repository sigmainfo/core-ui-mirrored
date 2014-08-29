class Spinach::Features::UserBrowsesRepositoryRootNode < Spinach::FeatureSteps

  include AuthSteps
  include Factory

  step 'a top level concept "Top Gun" exists' do
    @concept = create_concept_with_label "Top Gun"
  end

  step 'the name of the current repository is "Top Movies from the 80ies"' do
    current_repository.update_attributes name: "Top Movies from the 80ies"
  end

  step 'I visit the show concept page for "Top Gun"' do
    visit "/#{current_repository.id}/concepts/#{@concept['id']}"
  end

  step 'I should see a single repository node within the broader listing' do
    page.should have_css(".broader li .repository-label")
    page.all(".broader li .repository-label").size.should == 1
  end

  step 'this repository node should have the name "Top Movies from the 80ies"' do
    page.find(".broader li .repository-label").text.should == "Top Movies from the 80ies"
  end

  step 'I click on this repository node' do
    within ".broader" do
      click_link "Top Movies from the 80ies"
    end
  end

  step 'I should be on the repository root page of "Top Movies from the 80ies"' do
    page.should have_css(".repository.show")
    page.should have_css("h2.name", text: "Top Movies from the 80ies")
    current_path.should == "/#{current_repository.id}"
  end
end
