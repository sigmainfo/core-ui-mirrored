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

  And 'I am logged in' do
    page.execute_script "CoreClient.Auth.authenticate('#{me[:login]}', '#{me[:password]}');"
  end
end
