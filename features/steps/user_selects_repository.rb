class Spinach::Features::UserSelectsRepository < Spinach::FeatureSteps

  include AuthSteps

  step 'I have access to the repositories "Wild West" and "Branch of Service"' do
    @repository.update_attributes name: "Wild West"
    @repository2 = CoreClient::Auth::Repository.create! name: "Branch of Service", account_id: @account.id, graph_uri: "http://localhost:3336/", active: true
    @repo_user2 = CoreClient::Auth::RepositoryUser.create! repository: @repository2, user: @me, email: "nobody@blake.com", roles: [:user]
  end

  step 'I visit the application root' do
    visit "/"
  end

  step 'I should see the repository "Wild West" within the filters bar' do
    page.find("#coreon-filters").should have_text("Wild West")
  end

  step 'I should be on the root page of "Wild West"' do
    current_path.should == "/#{@repository.id}"
  end

  step 'I click the toggle of the repository selector' do
    page.find("#coreon-repository-select a.select").click
  end

  step 'I should see a dropdown with "Wild West" and "Branch of Service"' do
    within "#coreon-repository-select-dropdown" do
      page.should have_css("a", text: "Wild West")
      page.should have_css("a", text: "Branch of Service")
    end
  end

  step 'I should see "Wild West" being the currently selected repository' do
    within "#coreon-repository-select-dropdown" do
      page.should have_css(".selected", text: "Wild West")
    end
  end

  step 'I click on "Branch of Service"' do
    pending 'step not implemented'
  end

  step 'I should be on the root page of "Branch of Service"' do
    pending 'step not implemented'
  end

  step 'I should see the repository "Branch of Service" within the filters bar' do
    pending 'step not implemented'
  end

  step 'I should see "Branch of Service" being the currently selected repository' do
    pending 'step not implemented'
  end

  step 'I press the Escape key' do
    pending 'step not implemented'
  end

  step 'I should not see the dropdown' do
    pending 'step not implemented'
  end
end
