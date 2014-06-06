class Spinach::Features::UserAdjustsLayoutOfTextualViews < Spinach::FeatureSteps

  include AuthSteps

  step 'the widgets column has a width of 300px' do
    page.execute_script '$("#coreon-widgets .panel").width(300);'
  end

  step 'I visit the repository root page' do
    visit "/#{current_repository.id}"
  end

  step 'I drag the resize handle of the concept map to the left by 200px' do
    page.should have_css("#coreon-concept-map .ui-resizable-w")
    page.execute_script '$("#coreon-concept-map .ui-resizable-w").simulate("mouseover").simulate("drag", {dx: -200});'
  end

  step 'I should still be able to click the "NEW CONCEPT" button' do
    page.should have_css('a.button', text: 'NEW CONCEPT')
    page.find('a.button', text: 'NEW CONCEPT').click
  end
end
