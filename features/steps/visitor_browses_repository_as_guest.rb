class Spinach::Features::VisitorBrowsesRepositoryAsGuest < Spinach::FeatureSteps
  include Authentication

  step 'a public repository "Coreon Demo" exists' do
    guest = guest_account 'guest'
    repository = repository 'Coreon Demo'
    assign_roles guest, repository, :user
  end

  step 'I am not logged in' do
    pending 'step not implemented'
  end

  step 'I visit the welcome page' do
    pending 'step not implemented'
  end

  step 'I see a link "Login as guest"' do
    pending 'step not implemented'
  end

  step 'I click "Login as guest"' do
    pending 'step not implemented'
  end

  step 'I see "Logged in as guest"' do
    pending 'step not implemented'
  end

  step 'I am on the repository root page of "Coreon Demo"' do
    pending 'step not implemented'
  end
end
