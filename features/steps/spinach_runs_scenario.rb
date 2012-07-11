class SpinachRunsScenario < Spinach::FeatureSteps
  When 'I fail' do
    false.should == true
  end
end
