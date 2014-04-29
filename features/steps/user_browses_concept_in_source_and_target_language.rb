class Spinach::Features::UserBrowsesConceptInSourceAndTargetLanguage < Spinach::FeatureSteps

  include AuthSteps
  include LanguageSelectSteps
  include Api::Graph::Factory

  def term
    expect(page).to have_css('.concept.show .terms .term')
    page.find('.concept.show .terms .term')
  end

  def term_properties
    expect(term).to have_css('section.properties')
    term.find('section.properties')
  end

  def term_property(label)
    term.find('th', text: label).find(:xpath, 'following-sibling::td')
  end

  def term_property_tabs(label)
    term_property(label).all('ul.index li')
  end

  def term_property_selection(label)
    p = term_property(label)
    {
      tab:   p.find('ul.index  li.selected'),
      value: p.find('ul.values li.selected')
    }
  end

  step 'a concept' do
    @concept = create_concept nil
  end

  step 'a concept with the English term "firearm"' do
    @concept = create_concept nil
    @term = create_concept_term @concept, value: 'gun', lang: 'en'
  end

  step 'this concept has the following English terms: "gun", "firearm"' do
    create_concept_term @concept, value: 'gun', lang: 'en'
    create_concept_term @concept, value: 'firearm', lang: 'en'
  end

  step 'this concept has the following German terms: "Schusswaffe", "Flinte"' do
    create_concept_term @concept, value: 'Schusswaffe', lang: 'de'
    create_concept_term @concept, value: 'Flinte', lang: 'de'
  end

  step 'this concept hat the following Russian terms: "пистолет", "огнестрельное оружие"' do
    create_concept_term @concept, value: 'пистолет', lang: 'ru'
    create_concept_term @concept, value: 'огнестрельное оружие', lang: 'ru'
  end

  step 'this concept has the following Korean terms: "산탄 총", "총"' do
    create_concept_term @concept, value: '산탄 총', lang: 'ko'
    create_concept_term @concept, value: '총', lang: 'ko'
  end

  step 'I am on this concept\'s page' do
    visit "/#{current_repository.id}/concepts/#{@concept['id']}"
  end

  step 'I should see the languages in alphabetic order: "DE", "EN", "KO", "RU"' do
    sleep 0.2
    page.all(".concept .terms h3").map{|n| n.text}.should == [ "DE", "EN", "KO", "RU" ]
  end

  step 'I should see the languages in following order: "KO", "DE", "EN", "RU"' do
    sleep 0.2
    page.all(".concept .terms h3").map{|n| n.text}.should == [ "KO", "DE", "EN", "RU" ]
  end

  step 'I should see the languages in following order: "KO", "EN", "DE", "RU"' do
    sleep 0.2
    page.all(".concept .terms h3").map{|n| n.text}.should == [ "KO", "EN", "DE", "RU" ]
  end

  step 'I should see the languages in following order: "EN", "DE", "KO", "RU"' do
    sleep 0.2
    page.all(".concept .terms h3").map{|n| n.text}.should == [ "EN", "DE", "KO", "RU" ]
  end

  step 'I should see the languages in following order: "FR", "EN", "DE", "KO", "RU"' do
    sleep 0.2
    page.all(".concept .terms h3").map{|n| n.text}.should == [ "FR", "EN", "DE", "KO", "RU" ]
  end

  step 'I should see "No terms for this language" in the French section' do
    page.find(".concept .terms section.fr .no-terms").should have_text "No terms for this language"
  end

  step 'this concept hat the Russian property "description": "пистолет"' do
    create_concept_property @concept, key: 'description', value: 'пистолет', lang: 'ru'
  end

  step 'this concept has the English property "description": "gun"' do
    create_concept_property @concept, key: 'description', value: 'gun', lang: 'en'
  end

  step 'this concept has the Korean property "description": "산탄 총"' do
    create_concept_property @concept, key: 'description', value: '산탄 총', lang: 'ko'
  end

  step 'this concept has the German property "description": "Schusswaffe"' do
    create_concept_property @concept, key: 'description', value: 'Schusswaffe', lang: 'de'
  end

  step 'I should see "пистолет" displayed as property "description" of concept' do
    page.find(".concept > .properties ul.values li.selected").text.should == 'пистолет'
  end

  step 'I should see "Schusswaffe" displayed as property "description" of concept' do
    page.find(".concept > .properties ul.values li.selected").text.should == 'Schusswaffe'
  end

  step 'I should see "gun" displayed as property "description" of concept' do
    page.find(".concept > .properties ul.values li.selected").text.should == 'gun'
  end

  step 'I should see the property "description" of concept in following language order: "Russian", "English", "Korean", "German"' do
    page.all(".concept > .properties ul.index li").map{|n| n.text}.should == ["RU", "EN", "KO", "DE"]
  end

  step 'I should see the property "description" of concept in following language order: "German", "Russian", "English", "Korean"' do
    page.all(".concept > .properties ul.index li").map{|n| n.text}.should == ["DE", "RU", "EN", "KO"]
  end

  step 'I should see the property "description" of concept in following language order: "German", "English", "Russian", "Korean"' do
    page.all(".concept > .properties ul.index li").map{|n| n.text}.should == ["DE", "EN", "RU", "KO"]
  end

  step 'I should see the property "description" of concept in following language order: "English", "Russian", "Korean", "German"' do
    page.all(".concept > .properties ul.index li").map{|n| n.text}.should == ["EN", "RU", "KO", "DE"]
  end

  step 'a concept with an English term "rose" exists' do
    @concept = create_concept
    @term = create_concept_term @concept, value: 'rose', lang: 'en'
  end

  step 'it has an English description "A rose is a rose."' do
    create_concept_term_property @concept, @term,
                                 key: 'description', lang: 'en',
                                 value: 'A rose is a rose.'
  end

  step 'it has a German description "Eine Rose ist eine Rose."' do
    create_concept_term_property @concept, @term,
                                 key: 'description', lang: 'de',
                                 value: 'Eine Rose ist eine Rose.'
  end

  step 'it has a French description "Une rose est une rose."' do
    create_concept_term_property @concept, @term,
                                 key: 'description', lang: 'fr',
                                 value: 'Une rose est une rose.'
  end

  step 'it has a Greek description "Ένα τριαντάφυλλο είναι ένα τριαντάφυλλο."' do
    create_concept_term_property @concept, @term,
                              key: 'description', lang: 'el',
                              value: 'Ένα τριαντάφυλλο είναι ένα τριαντάφυλλο.'
  end

  step 'I visit the details page of this concept' do
    visit "/#{@repository.id}/concepts/#{@concept['id']}"
  end

  step 'I click "Toggle properties" on the term' do
    within term do
      expect(page).to have_css('h3[title="Toggle properties"]')
      page.find('h3[title="Toggle properties"]').click
    end
  end

  step 'I see a property group "DESCRIPTION"' do
    within term_properties do
      expect(page).to have_css('th', text: 'DESCRIPTION')
    end
  end

  step 'I see tabs "EN", "FR", "DE", "EL" in order' do
    tab_names = term_property_tabs('DESCRIPTION').map(&:text)
    expect(tab_names).to eql(['EN', 'FR', 'DE', 'EL'])
  end

  step 'the English description "A rose is a rose." is selected' do
    selection = term_property_selection('DESCRIPTION')
    expect(selection[:tab].text).to eql('EN')
    expect(selection[:value].text).to eql('A rose is a rose.')
  end

  step 'I see tabs "DE", "FR", "EN", "EL" in order' do
    tab_names = term_property_tabs('DESCRIPTION').map(&:text)
    expect(tab_names).to eql(['DE', 'FR', 'EN', 'EL'])
  end

  step 'the German description "Eine Rose ist eine Rose." is selected' do
    selection = term_property_selection('DESCRIPTION')
    expect(selection[:tab].text).to eql('DE')
    expect(selection[:value].text).to eql('Eine Rose ist eine Rose.')
  end

  step 'I see tabs "DE", "EN", "FR", "EL" in order' do
    tab_names = term_property_tabs('DESCRIPTION').map(&:text)
    expect(tab_names).to eql(["DE", "EN", "FR", "EL"])
  end
end
