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

  step 'I click "OK" within the dialog' do
    page.find(".confirm p", text: "OK").click
  end

  step 'I click outside the dialog' do
    page.execute_script '$(".modal-shim").css({height: 300})'
    page.find(".modal-shim").click
  end

  step 'I should not see a confirmation dialog' do
    page.should have_no_css(".confirm")
  end
end
