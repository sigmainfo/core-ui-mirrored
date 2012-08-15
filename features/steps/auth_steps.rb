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
    Given 'my name is "William Blake" with login "Nobody" and password "se7en!"' unless me
    page.execute_script "CoreClient.Auth.authenticate('#{me[:login]}', '#{me[:password]}')"
    wait_until { page.evaluate_script "CoreClient.Auth.isAuthenticated()" }
    page.execute_script "Coreon.application.account.trigger('login')"
  end

  Given 'I am logged out' do
    page.execute_script "CoreClient.Auth.authenticate(false);"
    page.execute_script "Coreon.application.account.trigger('logout')"
  end
end
