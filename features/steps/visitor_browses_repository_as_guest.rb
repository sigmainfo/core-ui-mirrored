class Spinach::Features::VisitorBrowsesRepositoryAsGuest < Spinach::FeatureSteps
  include Authentication

  step 'a public repository "Coreon Demo" exists' do
    @current_repository = create_repository 'Coreon Demo'
    grant_repository_access :user, user: guest_user
  end

  step 'I am not logged in' do
    logout
  end

  step 'I visit the welcome page' do
    visit '/'
  end

  step 'I see a link "Log in as guest"' do
    expect(page).to have_link('Log in as guest')
  end

  step 'I click "Log in as guest"' do
    click_link 'Log in as guest'
  end

  step 'I see "Logged in as guest"' do
    expect(page).to have_content('Logged in as guest')
  end

  step 'I am on the repository root page of "Coreon Demo"' do
    expect(page).to have_content('Coreon Demo')
    expect(current_path).to eql("/#{current_repository.id}")
  end
end
