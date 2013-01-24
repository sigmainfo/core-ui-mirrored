module AuthSteps
  include Spinach::DSL

  attr_accessor :me

  Given 'my name is "William Blake" with login "Nobody" and password "se7en!"' do
    self.me = {
      name: "William Blake",
      login: "Nobody",
      password: "se7en!"
    }
    CoreClient::Auth.create_user me[:name], me[:login], me[:password]
  end

  Given 'I am logged in' do
    page.execute_script "Coreon.application.account.deactivate();"
    page.execute_script "Coreon.application.account.activate('#{me[:login]}', '#{me[:password]}');"
    page.should  have_css("a.logout")
    CoreAPI.session = page.evaluate_script "Coreon.application.account.get('session')"
  end

  Given 'I am logged out' do
    page.execute_script "Coreon.application.account.deactivate();"
  end
end
