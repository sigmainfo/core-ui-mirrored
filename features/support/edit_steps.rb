require_relative 'editing'

module EditSteps
  include Spinach::DSL
  include Editing

  step 'I have maintainer privileges' do
    page.execute_script 'Coreon.application.get("session").currentRepository().set("user_roles", ["maintainer"])'
  end

  step 'I do not have maintainer privileges' do
    page.execute_script 'Coreon.application.get("session").currentRepository().set("user_roles", ["user"])'
  end

  step 'client-side validation is turned off' do
    page.execute_script '$("form").attr("novalidate", true)'
  end

  step 'I should see an error summary' do
    page.should have_css("form .error-summary")
  end

  step 'I should not see a confirmation dialog' do
    page.should have_no_selector(:confirmation_dialog)
  end

  step 'I toggle "EDIT MODE"' do
    expect(page).to have_selector(:link, 'Edit mode')
    click_link "Edit mode"
  end

  step 'I am on the edit concept details page' do
    edit_concept_details @concept
  end
end
