module AuthSteps
  include Spinach::DSL

  attr_accessor :me

  Given 'my name is "William Blake" with email "nobody@blake.com" and password "se7en!"' do    
    @me_password = "se7en!"
    @me = CoreClient::Auth::User.create!(
      name: "William Blake",
      emails: ["nobody@blake.com"],
      password: @me_password,
      password_confirmation: @me_password
    )  
  end

  Given 'I am logged in' do
    page.execute_script "Coreon.application.session.deactivate();"
    page.execute_script "Coreon.application.session.activate('#{@me.emails.first}', '#{@me_password}');"
    page.should have_css("#coreon-footer")
    CoreAPI.session = page.evaluate_script "Coreon.application.session.get('token')"
  end

  Given 'I am logged out' do
    visit "/logout"
  end
end
