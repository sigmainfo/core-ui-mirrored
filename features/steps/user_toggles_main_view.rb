class Spinach::Features::UserTogglesMainView < Spinach::FeatureSteps

  include AuthSteps
  include SearchSteps
  include Api::Graph::Factory

  def main_view
    find '#coreon-main'
  end

  step 'a concept "Monitor" exists' do
    @parent = create_concept_with_label 'Monitor'
  end

  step 'this concept has narrower concepts "LCD Screen" and "TFT Screen"' do
    [ 'LCD Screen', 'TFT Screen' ].each do |label|
      create_concept_with_label label, superconcept_ids: [ @parent['id'] ]
    end
  end

  step 'I should see a widget "Concept Map"' do
    page.should have_selector( :widget, 'Concept Map' )
    @current = find( :widget, 'Concept Map' )
  end

  step 'it should contain nodes "Monitor", "LCD Screen", and "TFT Screen"' do
    within @current do
      [ 'Monitor', 'LCD Screen', 'TFT Screen' ].each do |label|
        page.should have_selector( :concept_node, label )
      end
    end
  end

  step 'I should see listing "Concepts" inside the main view' do
    within main_view do
      page.should have_selector( :listing, 'Concepts' )
      @current = find( :listing, 'Concepts' )
    end
  end

  step 'it should contain items "LCD Screen" and "TFT Screen"' do
    within @current do
      [ 'LCD Screen', 'TFT Screen' ].each do |label|
        page.should have_css( 'tr .label', text: label )
      end
    end
  end

  step 'I click on "Maximize" inside the widget "Concept Map"' do
    within :widget, 'Concept Map' do
      click_on 'Maximize'
    end
  end

  step 'I should not see a widget "Concept Map"' do
    pending 'step not implemented'
  end

  step 'I should see a concept map inside the main view' do
    pending 'step not implemented'
  end

  step 'I should see a widget "Concepts"' do
    pending 'step not implemented'
  end

  step 'I click on "Maximize" inside the widget "Concepts"' do
    pending 'step not implemented'
  end

  step 'I should not see a widget "Concepts"' do
    pending 'step not implemented'
  end

  step 'I click on "Maximize" inside the widget "Clipboard"' do
    pending 'step not implemented'
  end

  step 'I should not see a widget "Clipboard"' do
    pending 'step not implemented'
  end

  step 'I should see a caption "CLIPBOARD" inside the main view' do
    pending 'step not implemented'
  end

  step 'I click on "Maximize" inside the widget "Term List"' do
    pending 'step not implemented'
  end

  step 'I should not see a widget "Term List"' do
    pending 'step not implemented'
  end

  step 'I should see a widget "Clipboard"' do
    pending 'step not implemented'
  end

  step 'I should see a caption "TERM LIST" inside the main view' do
    pending 'step not implemented'
  end
end
