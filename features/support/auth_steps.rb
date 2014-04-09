require_relative 'authentication'

module AuthSteps
  include Spinach::DSL
  include Authentication

  step 'my name is "William Blake" with email "nobody@blake.com" and password "se7en!"' do
    @current_user = create_user(
      'William Blake',
      'nobody@blake.com',
      password: 'se7en!'
    )
    @repository_user = create_repository_user
  end

  step 'I am a user of the repository' do
    @repository_user = repository_user
  end

  step 'I am logged in as user of the repository' do
    @repository_user ||= create_repository_user
    login
  end

  step 'I am logged in as maintainer of the repository' do
    @repository_user = create_repository_user(:maintainer)
  end

  step 'I am no maintainer of the repository' do
    # set user_name to mark user as dirty
    @repository_user.update_attributes roles: ["user"], user_name: "123"
  end

  step 'I am a maintainer of the repository' do
    # set user_name to mark user as dirty
    @repository_user.update_attributes roles: ["user", "maintainer"], user_name: "xxx"
  end

  step 'I am logged in' do
    login email: 'nobody@blake.com', password: 'se7en!'
  end

  step 'I am logged out' do
    logout
  end

  step 'I visit the repository root page' do
    visit "/#{current_repository.id}"
  end
end
