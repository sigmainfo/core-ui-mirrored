module EditSteps
  include Spinach::DSL

  step 'I have maintainer privileges' do
    page.execute_script 'Coreon.application.session.ability.set("role", "maintainer");'
  end

  step 'client-side validation is turned off' do
    page.execute_script '$("form").attr("novalidate", true)'
  end

  step 'I should see an error summary' do
    page.should have_css("form .error-summary")
  end
end
