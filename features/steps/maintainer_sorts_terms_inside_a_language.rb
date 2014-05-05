class Spinach::Features::MaintainerSortsTermsInsideALanguage < Spinach::FeatureSteps

  include AuthSteps
  include Api::Graph::Factory

  def language(id)
    page.find ".language.#{id.downcase}"
  end

  step 'a concept with English terms "pistol", "handgun", and "revolver"' do
    @concept  = create_concept
    @pistol   = create_concept_term @concept, lang: 'en', value: 'pistol'
    @handgun  = create_concept_term @concept, lang: 'en', value: 'handgun'
    @revolver = create_concept_term @concept, lang: 'en', value: 'revolver'
  end

  step '"revolver" has a precedence of 1' do
    create_concept_term_property @concept, @revolver,
                                 key: 'precedence', value: 1
  end

  step '"pistol" has a precedence of 2' do
    create_concept_term_property @concept, @pistol,
                                 key: 'precedence', value: 2
  end

  step '"handgun" has a precedence of 3' do
    create_concept_term_property @concept, @handgun,
                                 key: 'precedence', value: 3
  end

  step 'I visit the concept details page' do
    visit "/#{@repository.id}/concepts/#{@concept['id']}"
  end

  step 'I see all 3 terms inside language "EN"' do
    within language(:en) do
      page.should have_css('.term', count: 3)
      @terms = page.all('.term')
    end
  end

  step 'they have the following order: "revolver", "pistol", "handgun"' do
    @terms.map do |term|
      term.first('.value').text
    end.should == ['revolver', 'pistol', 'handgun']
  end

  step 'I see no properties on any of them' do
    within language(:en) do
      page.should have_no_css('.term .properties')
    end
  end

  step 'I toggle "EDIT MODE"' do
    click_on "Edit mode"
  end

  step 'I see a drag handler inside each term' do
    within language(:en) do
      @terms = page.all('.term')
      @terms.each do |term|
        term.should have_css('.drag-handle')
      end
    end
  end

  step 'I drag "handgun" to the top of the list' do
    pending 'step not implemented'
  end

  step 'the order of the terms has changed to "handgun", "revolver", "pistol"' do
    pending 'step not implemented'
  end

  step 'I reload the concept details page' do
    pending 'step not implemented'
  end

  step 'the order of the terms is still "handgun", "revolver", "pistol"' do
    pending 'step not implemented'
  end
end