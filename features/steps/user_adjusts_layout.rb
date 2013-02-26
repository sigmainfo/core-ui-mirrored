class Spinach::Features::UserAdjustsLayout < Spinach::FeatureSteps

  include AuthSteps

  step 'the widgets column has a width of 300px' do
    page.execute_script '$("#coreon-widgets").width(300);'
  end

  step 'the concept map widget has a height of 240px' do
    page.execute_script '$("#coreon-concept-map").height(240);'
  end

  step 'I drag the resize handle of the widgets column to the left by 150px' do
    page.should have_css("#coreon-widgets .ui-resizable-w")
    page.execute_script '$("#coreon-widgets .ui-resizable-w").simulate("mouseover").simulate("drag", {dx: -150});'
  end

  step 'I should see the widgets column being 450px wide' do
    page.evaluate_script('$("#coreon-widgets").width();').should == 450
  end

  step 'I should see the concept map widget keeping its height of 240px' do
    page.evaluate_script('$("#coreon-concept-map").height();').should == 240
  end

  step 'I drag the bottom resize handler of the concept map widget down by 50px' do
    page.should have_css("#coreon-concept-map .ui-resizable-s")
    page.execute_script '$("#coreon-concept-map .ui-resizable-s").simulate("mouseover").simulate("drag", {dy: 50});'
  end

  step 'I should see the concept map widget being 290px high' do
    pending 'step not implemented'
  end

  step 'I drag the bottom resize handler of the concept map widget up by 230px' do
    pending 'step not implemented'
  end

  step 'I should see the concept map widget having its minimal height of 80px' do
    pending 'step not implemented'
  end

  step 'I drag the resize handle of the widgets column to the right by 300px' do
    pending 'step not implemented'
  end

  step 'I should see the widgets column having a minimal width of 120px' do
    pending 'step not implemented'
  end
end
