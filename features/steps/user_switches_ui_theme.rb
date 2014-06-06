class Spinach::Features::UserSwitchesUiTheme < Spinach::FeatureSteps

  include AuthSteps

  step 'I am on the repository root page' do
    visit "/#{current_repository.id}"
  end

  step 'I click to toggle the footer' do
    within '#coreon-footer' do
      page.find('.toggle').click
    end
  end

  step 'I click on theme "High contrast"' do
    within '#coreon-footer' do
      page.click_link 'High Contrast'
    end
  end

  step 'the body should have a pure white background' do
    sleep 1
    bg = page.evaluate_script '$("body").css("backgroundImage")'
    bg.should == 'none'
  end

  step 'I click on theme "Default"' do
    within '#coreon-footer' do
      page.click_link 'Default'
    end
  end

  step 'the body should have a background image applied to it' do
    sleep 1
    bg = page.evaluate_script '$("body").css("backgroundImage")'
    bg.should include('url')
  end
end
