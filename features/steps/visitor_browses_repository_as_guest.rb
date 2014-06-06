class Spinach::Features::VisitorBrowsesRepositoryAsGuest < Spinach::FeatureSteps
  include Authentication

  step 'a public repository "Coreon Demo" exists' do
    grant_repository_access :user, user: guest_user
  end

  step 'I am not logged in' do
    logout
  end

  step 'I visit the welcome page' do
    visit '/'
  end

  step 'I see a link "Login as guest"' do
    expect(page).to have_link('Login as guest')
  end

  step 'I click "Login as guest"' do
    click_link 'Login as guest'
  end

  step 'I see "Logged in as guest"' do
    pending 'step not implemented'
  end

  step 'I am on the repository root page of "Coreon Demo"' do
    pending 'step not implemented'
  end
end
