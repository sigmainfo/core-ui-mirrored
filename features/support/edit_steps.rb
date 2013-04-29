module EditSteps
  include Spinach::DSL

  step 'I have maintainer privileges' do
    page.execute_script 'Coreon.application.session.ability.set("role", "maintainer");'
  end
end
