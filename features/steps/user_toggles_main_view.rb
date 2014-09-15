class Spinach::Features::UserTogglesMainView < Spinach::FeatureSteps

  include AuthSteps
  include SearchSteps
  include Factory

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

  step 'I should see the panel "Concepts" inside the main view' do
    within main_view do
      page.should have_selector( :panel, 'Concepts' )
      @current = find( :panel, 'Concepts' )
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
    page.should have_no_selector( :widget, 'Concept Map' )
  end

  step 'I should see a concept map inside the main view' do
    within main_view do
      page.should have_selector(:panel, 'Concept Map')
      @current = find( :panel, 'Concept Map' )
    end
  end

  step 'I should see a widget "Concepts"' do
    page.should have_selector( :widget, 'Concepts' )
    @current = find( :widget, 'Concepts' )
  end

  step 'I click on "Maximize" inside the widget "Concepts"' do
    within :widget, 'Concepts' do
      click_on 'Maximize'
    end
  end

  step 'I should not see a widget "Concepts"' do
    page.should have_no_selector( :widget, 'Concepts' )
  end

  step 'I should see "Concepts" inside the main view' do
    within main_view do
      page.should have_selector(:panel, 'Concepts')
      @current = find( :panel, 'Concepts' )
    end
  end

  step 'I click on "Maximize" inside the widget "Clipboard"' do
    within :widget, 'Clipboard' do
      click_on 'Maximize'
    end
  end

  step 'I should not see a widget "Clipboard"' do
    page.should have_no_selector( :widget, 'Clipboard' )
  end

  step 'I should see a caption "CLIPBOARD" inside the main view' do
    within main_view do
      page.should have_css('.titlebar h3', text: 'CLIPBOARD')
    end
  end

  step 'I click on "Maximize" inside the widget "Term List"' do
    within :widget, 'Term List' do
      click_on 'Maximize'
    end
  end

  step 'I should not see a widget "Term List"' do
    page.should have_no_selector( :widget, 'Term List' )
  end

  step 'I should see a widget "Clipboard"' do
    page.should have_selector( :widget, 'Clipboard' )
  end

  step 'I should see a caption "TERM LIST" inside the main view' do
    within main_view do
      page.should have_css('.titlebar h3', text: 'TERM LIST')
    end
  end
end
