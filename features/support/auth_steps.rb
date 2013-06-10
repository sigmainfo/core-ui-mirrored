module AuthSteps
  include Spinach::DSL

  attr_accessor :me

  Given 'my name is "William Blake" with login "Nobody" and password "se7en!"' do
    @me_password = "se7en!"
    @me = CoreClient::Auth::User.create!(
      name: "William Blake",
      login: "Nobody",
      password: @me_password,
      password_confirmation: @me_password
    )  
  end

  Given 'I am logged in' do
    page.execute_script "Coreon.application.session.deactivate();"
    page.execute_script "Coreon.application.session.activate('#{@me.login}', '#{@me_password}');"
    page.should have_css("#coreon-footer")
    CoreAPI.session = page.evaluate_script "Coreon.application.session.get('token')"
  end

  Given 'I am logged out' do
    page.execute_script "Coreon.application.session.deactivate();"
  end
end
