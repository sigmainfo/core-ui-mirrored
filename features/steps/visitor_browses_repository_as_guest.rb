class Spinach::Features::VisitorBrowsesRepositoryAsGuest < Spinach::FeatureSteps
  include Authentication
  include Factory
  include Navigation

  attr :concept

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

  step 'a concept "Example" exists' do
    @concept = create_concept_with_label 'Example'
  end

  step 'I follow a public link to this concept' do
    visit_concept_details_page concept, guest: 1
  end

  step 'I see the concept details for "Example"' do
    within '.concept-head' do
      expect(page).to have_selector('.concept-label', text: 'Example')
    end
  end
end
