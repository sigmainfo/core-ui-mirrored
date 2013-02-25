# encoding: utf-8
class UserBrowsesSingleConcept < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps
  include Api::Graph::Factory

  def click_on_toggle(name)
    find(:xpath, "//*[contains(@class, 'section-toggle') and text() = '#{name}']").click
  end

  def section_for(name)
    find :xpath, "//*[contains(@class, 'section-toggle') and text() = '#{name}']/following-sibling::*[contains(@class, 'section')]"
  end

  Given 'a concept with label "handgun"' do
    @handgun = create_concept properties: [{key: 'label', value: 'handgun'}]
  end

  And 'this concept has an English definition with value "A portable firearm"' do
    create_concept_property @handgun, key: "definition", value: "A portable firearm", lang: "en"
  end

  And 'this concept has an German definition with value "Tragbare Feuerwaffe"' do
    create_concept_property @handgun, key: "definition", value: "Tragbare Feuerwaffe", lang: "de"
  end

  And 'this concept has a property "notes" with value "Bitte überprüfen!!!"' do
    @prop = create_concept_property @handgun, key: "notes", value: "Bitte überprüfen!!!"
  end

  And 'this concept has the following English terms: "gun", "firearm", "shot gun", "musket"' do
    ["gun", "firearm", "shot gun", "musket"].each do |value|
      create_concept_term @handgun, value: value, lang: "en"
    end
  end

  And 'this concept has the following German terms: "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"' do
    @handgun_terms = {}
    ["Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"].each do |value|
      @handgun_terms[value] = create_concept_term @handgun, value: value, lang: "de"
    end
  end

  And 'the term "Schusswaffe" should have property "gender" with value "f"' do
    create_concept_term_property @handgun, @handgun_terms["Schusswaffe"], key: "gender", value: "f"
  end

  And 'given a broader concept with label "weapon"' do    
    weapon = create_concept properties: [{key: 'label', value: 'weapon'}], sub_concepts: [@handgun['_id']]
  end

  And 'given a narrower concept with label "pistol"' do
    pistol = create_concept properties: [{key: 'label', value: 'pistol'}], super_concepts: [@handgun['_id']]
  end

  And 'given a narrower concept with label "revolver"' do
    revolver = create_concept properties: [{key: 'label', value: 'revolver'}], super_concepts: [@handgun['_id']]
  end

  And 'this property has an attribute "author" of "William"' do
    update_concept_property @handgun, @prop, author: 'William'
  end

  And 'this concept has a property "notes" with value "I\'m not dead. Am I?"' do
    @prop = create_concept_property @handgun, key: "notes", value: "I\'m not dead. Am I?"
  end

  And 'this property has an attribute "author" of "Nobody"' do
    update_concept_property @handgun, @prop, author: 'Nobody'
  end

  And 'this concept has a term "shot gun"' do
    @term = create_concept_term @handgun, value: "shot gun", lang: "en"
  end

  And 'this term has an attribute "legacy_id" of "543"' do
    update_concept_term @handgun, @term, legacy_id: '543'
  end

  And 'this term has a property "parts of speach" with value "noun"' do
    @prop = create_concept_term_property @handgun, @term, key: "parts of speach", value: "noun"
  end

  And 'this property has an attribute "author" of "Mr. Blake"' do
    update_concept_term_property @handgun, @term, @prop, author: "Mr. Blake"
  end

  And 'I click on the label "handgun"' do
    page.find(".concepts a.concept-label", text: "handgun").click
  end

  Then 'I should be on the show concept page for "handgun"' do
    current_path.should == "/concepts/#{@handgun['_id']}"
  end

  And 'I should see the label "handgun"' do
    page.find(".concept .label").should have_content("handgun")
  end

  And 'I should see the section "BROADER & NARROWER"' do
    page.should have_css("h3.section-toggle", text: "BROADER & NARROWER")
  end

  And 'this section should display "pistol" as being narrower' do
    page.should have_css(".sub .concept-label", text: "pistol")
  end

  And 'it should display "revolver" as being narrower' do
    page.should have_css(".sub .concept-label", text: "revolver")
  end

  And 'it should display "weapon" as being broader' do
    page.should have_css(".super .concept-label", text: "weapon")
  end

  And 'I should see the section "PROPERTIES"' do
    page.should have_css("h3.section-toggle", text: "PROPERTIES")
  end

  And 'it should have an English property "DEFINITION" with value "A portable firearm"' do
    @td = page.find("th", text: "DEFINITION").find :xpath, "parent::*/td"
    @td.find("ul.index li.selected").text.should == "EN"
    @td.find("ul.values li", visible: true).text.should == "A portable firearm"
  end

  When 'I click on "de" for that property' do
    @td.find("ul.index li a", text: "DE").click
  end

  Then 'the value should have changed to "Tragbare Feuerwaffe"' do
    @td.find("ul.values li", visible: true).text.should == "Tragbare Feuerwaffe"
  end

  And 'it should have a property "NOTES" with value "Bitte überprüfen!!!"' do
    @td = page.find("th", text: "NOTES").find :xpath, "parent::*/td"
    @td.text.should == "Bitte überprüfen!!!"
  end

  And 'I should see a section for locale "EN"' do
    page.should have_css("h3.section-toggle", text: "EN")
    @lang = page.find :xpath, "//h3[contains(@class, 'section-toggle') and text()='en']/following-sibling::div[contains(@class, 'section')]"
  end

  And 'it shoud have the following terms "gun", "firearm", "shot gun", "musket"' do
    ["gun", "firearm", "shot gun", "musket"].each do |term|
      @lang.should have_content(term)
    end
  end

  And 'I should see a section for locale "DE"' do
    page.should have_css("h3.section-toggle", text: "DE")
    @lang = page.find :xpath, "//h3[contains(@class, 'section-toggle') and text()='de']/following-sibling::div[contains(@class, 'section')]"
  end

  And 'it shoud have the following terms "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"' do
    ["Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"].each do |term|
      @lang.should have_content(term)
    end
  end

  When 'I click on toggle "PROPERTIES" of term "Schusswaffe"' do
    page.find(:xpath, "//*[contains(@class, 'value') and text() = 'Schusswaffe']/following-sibling::*[contains(@class, 'properties')]/*[contains(@class, 'section-toggle')]").click
  end

  Then 'I should see property "GENDER" with value "f"' do
    page.should have_css(".term .properties th", text: "GENDER")
    page.find(:xpath, "//th[text() = 'gender']/following-sibling::td").text.should == "f"
  end

  When 'I click on the toggle of the locale "EN"' do
    click_on_toggle "en"
  end

  Then 'the locale should be hidden' do
    section_for("en").should_not be_visible
  end

  Then 'I should see the term "gun"' do
    page.should have_css(".term .value", text: "gun")
  end

  When 'I click on the toggle "BROADER & NARROWER"' do
    page.execute_script "$('.notification .hide').click()"
    click_on_toggle "Broader & Narrower"
  end

  Then 'the concept tree should be hidden' do
    section_for("Broader & Narrower").should_not be_visible
  end

  When 'I click on the toggle "PROPERTIES"' do
    click_on_toggle "Properties"
  end

  Then 'the concept properties should be hidden' do
    section_for("Properties").should_not be_visible
  end

  When 'I click the toggle "System Info" on the concept' do
    page.find(:xpath, "//*[@class='concept']/*[contains(@class, 'system-info-toggle') and text() = 'System Info']").click
  end

  Then 'I should see "id" of the "handgun" concept' do
    page.find(:xpath, "//*[@class='concept']/div[@class='system-info']//th[text()='id']/following-sibling::td[1]").should have_content(@handgun['_id'])
  end

  And 'I should see "AUTHOR" with value "William" for property "notes"' do
    page.find(:xpath, "//*[@class='properties']//th[text()='notes']/following-sibling::td//li[not(contains(@style, 'none'))]//th[text()='author']/following-sibling::td").should have_content("William")
  end

  When 'I click on index item "2" for property "notes"' do
    page.find(:xpath, "//*[@class='properties']//th[text()='notes']/following-sibling::td/ul[@class='index']/li/a[@data-index='1']").click
  end

  Then 'I should see "author" with value "Nobody" for property "notes"' do
    page.find(:xpath, "//*[@class='properties']//th[text()='notes']/following-sibling::td/ul[@class='values']/li[not(contains(@style, 'none'))]//th[text()='author']/following-sibling::td").should have_content("Nobody")
  end

  Then 'I should not see information for "id" or "author"' do
    page.should_not have_css(".system-info th", text: "id")
    page.should_not have_css(".system-info th", text: "author")
  end

  When 'I click the toggle "System Info" on the term "shot gun"' do
    page.find(:xpath, "//*[contains(@class, 'term')]/*[contains(@class, 'value') and text() = 'shot gun']/following-sibling::*[contains(@class, 'system-info-toggle') and text() = 'System Info']").click
  end

  Then 'I should see "legacy_id" with value "543" for this term' do
    info = page.find(:xpath, "//*[contains(@class, 'term')]/*[contains(@class, 'value') and text() = 'shot gun']/following-sibling::*[@class = 'system-info']")
    info.should have_css("th", text: "legacy_id")
    info.should have_css("td", text: "543")
  end

  When 'I click on the toggle "Properties" for this term' do
    page.find(:xpath, "//*[contains(@class, 'term')]/*[contains(@class, 'value') and text() = 'shot gun']/following-sibling::*[@class = 'properties']/*[contains(@class, 'section-toggle')]").click
  end

  Then 'I should see "author" with value "Mr. Blake" for property "parts of speach"' do
    td = page.find(:xpath, "//*[contains(@class, 'term')]/*[contains(@class, 'value') and text() = 'shot gun']/following-sibling::*[@class = 'properties']//th[text() = 'parts of speach']/following-sibling::td")
    td.should have_css(".system-info th", text: "author") 
    td.should have_css(".system-info td", text: "Mr. Blake") 
  end
end
