# encoding: utf-8
class UserBrowsesSingleConcept < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps
  include Api::Graph::Factory

  def click_on_toggle(name)
    find("section *:first-child", text: name).click
  end

  def section_for(name)
    find("section *:first-child", text: name).find(:xpath, "./following-sibling::*[1]", visible: false)
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
  
  And 'the term "Flinte" should have property "status" with value "pending"' do
    create_concept_term_property @handgun, @handgun_terms["Flinte"], key: "status", value: "pending"
  end

  And 'given a broader concept with label "weapon"' do
    weapon = create_concept properties: [{key: 'label', value: 'weapon'}], subconcept_ids: [@handgun['id']]
  end

  And 'given a narrower concept with label "pistol"' do
    pistol = create_concept properties: [{key: 'label', value: 'pistol'}], superconcept_ids: [@handgun['id']]
  end

  And 'given a narrower concept with label "revolver"' do
    revolver = create_concept properties: [{key: 'label', value: 'revolver'}], superconcept_ids: [@handgun['id']]
  end

  And 'this property has an attribute "author" of "William"' do
    update_concept_property @handgun, @prop, admin: {author: 'William'}
  end

  And 'this concept has a property "notes" with value "I\'m not dead. Am I?"' do
    @prop = create_concept_property @handgun, key: "notes", value: "I\'m not dead. Am I?"
  end

  And 'this property has an attribute "author" of "Nobody"' do
    update_concept_property @handgun, @prop, admin: {author: 'Nobody'}
  end

  And 'this concept has a term "shot gun"' do
    @term = create_concept_term @handgun, value: "shot gun", lang: "en"
  end

  And 'this term has an attribute "legacy_id" of "543"' do
    update_concept_term @handgun, @term, admin: {legacy_id: '543'}
  end

  And 'this term has a property "parts of speach" with value "noun"' do
    @prop = create_concept_term_property @handgun, @term, key: "parts of speach", value: "noun"
  end

  And 'this property has an attribute "author" of "Mr. Blake"' do
    update_concept_term_property @handgun, @term, @prop, admin: {author: "Mr. Blake"}
  end

  And 'I click on the label "handgun"' do
    page.find(".concepts a.concept-label", text: "handgun").click
  end

  Then 'I should be on the show concept page for "handgun"' do
    current_path.should == "/#{@repository.id}/concepts/#{@handgun['id']}"
  end

  And 'I should see the label "handgun"' do
    page.find(".concept .label").should have_content("handgun")
  end

  And 'I should see the section "BROADER & NARROWER"' do
    page.should have_css("section h3", text: "BROADER & NARROWER")
  end

  And 'this section should display "pistol" as being narrower' do
    page.should have_css(".narrower .concept-label", text: "pistol")
  end

  And 'it should display "revolver" as being narrower' do
    page.should have_css(".narrower .concept-label", text: "revolver")
  end

  And 'it should display "weapon" as being broader' do
    page.should have_css(".broader .concept-label", text: "weapon")
  end

  And 'I should see the section "PROPERTIES"' do
    page.should have_css("section h3", text: "PROPERTIES")
  end

  And 'it should have an English property "DEFINITION" with value "A portable firearm"' do
    @td = page.find("th", text: "DEFINITION").find :xpath, "parent::*/td"
    @td.find("ul.index li.selected").text.should == "EN"
    @td.find("ul.values li.selected").text.should == "A portable firearm"
  end

  When 'I click on "DE" for that property' do
    @td.find("ul.index li", text: "DE").click
  end

  Then 'the value should have changed to "Tragbare Feuerwaffe"' do
    @td.find("ul.values li.selected").text.should == "Tragbare Feuerwaffe"
  end

  And 'it should have a property "NOTES" with value "Bitte überprüfen!!!"' do
    @td = page.find("th", text: "NOTES").find :xpath, "parent::*/td"
    @td.text.should == "Bitte überprüfen!!!"
  end

  And 'I should see a section for locale "EN"' do
    page.should have_css("section.language.en h3")
    @lang = page.find("section.language.en ul")
  end

  And 'it shoud have the following terms "gun", "firearm", "shot gun", "musket"' do
    ["gun", "firearm", "shot gun", "musket"].each do |term|
      @lang.should have_content(term)
    end
  end

  And 'I should see a section for locale "DE"' do
    page.should have_css("section.language.de h3", text: "DE")
    @lang = page.find("section.language.de ul")
  end

  And 'it shoud have the following terms "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"' do
    ["Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"].each do |term|
      @lang.should have_content(term)
    end
  end

  When 'I click on toggle "PROPERTIES" of term "Schusswaffe"' do
    page.find(".term .value", text: "Schusswaffe").find(:xpath, "./following-sibling::section[contains(@class, 'properties')]/h3").click
  end

  Then 'I should see property "GENDER" with value "f"' do
    sleep 1
    page.find(:xpath, "//th[text() = 'gender']/following-sibling::td").text.should == "f"
  end
  
  When 'I click on toggle "TOGGLE ALL PROPERTIES"' do
    page.find(".properties-toggle").click
  end
  
  Then 'I should see property "status" with value "pending"' do
    sleep 1
    page.find(:xpath, "//th[text() = 'status']/following-sibling::td").text.should == "pending"
  end

  When 'I click on the toggle of the locale "EN"' do
    click_on_toggle "EN"
  end

  Then 'the locale should be hidden' do
    section_for("EN").should_not be_visible
  end

  Then 'I should see the term "gun"' do
    page.should have_css(".term .value", text: "gun")
  end

  When 'I click on the toggle "BROADER & NARROWER"' do
    page.execute_script "$('.notification .hide').click()"
    click_on_toggle "BROADER & NARROWER"
  end

  Then 'the section "BROADER & NARROWER" should be hidden' do
    section_for("BROADER & NARROWER").should_not be_visible
  end

  When 'I click on the toggle "PROPERTIES"' do
    click_on_toggle "PROPERTIES"
  end

  Then 'the concept properties should be hidden' do
    section_for("PROPERTIES").should_not be_visible
  end

  When 'I click the toggle "System Info" on the concept' do
    page.find(".concept .system-info-toggle", text: "System Info").click
  end

  Then 'I should see "id" of the "handgun" concept' do
    page.find(".concept .concept-head .system-info").find(:xpath, ".//th[text()='id']/following-sibling::td[1]").should have_content(@handgun["id"])
  end

  And 'I should see "author" with value "William" for property "NOTES"' do
    page.find(".concept > .properties th", text: "NOTES").find(:xpath, "./following-sibling::td[1]//th[text()='author']/following-sibling::td[1]").should have_content("William")
  end

  When 'I click on index item "2" for property "NOTES"' do
    page.find(".concept > .properties th", text: "NOTES").find(:xpath, "./following-sibling::td[1]//ul[@class='index']/li[@data-index='1']").click
  end

  Then 'I should see "author" with value "Nobody" for property "notes"' do
    page.find(:xpath, "//*[@class='properties']//th[text()='notes']/following-sibling::td/ul[@class='values']/li[not(contains(@style, 'none'))]//th[text()='author']/following-sibling::td").should have_content("Nobody")
  end

  Then 'I should not see information for "id", "author", and "legacy_id"' do
    page.should_not have_css(".system-info th", text: "id")
    page.should_not have_css(".system-info th", text: "author")
    page.should_not have_css(".system-info th", text: "legacy_id")
  end

  And 'I should see "legacy_id" with value "543" for term "shot gun"' do
    info = page.find(:xpath, "//*[contains(@class, 'term')]/*[contains(@class, 'value') and text() = 'shot gun']/following-sibling::*[@class = 'system-info']")
    info.should have_css("th", text: "legacy_id")
    info.should have_css("td", text: "543")
  end

  When 'I click on the toggle "PROPERTIES" for term "shot gun"' do
    page.find(".term .value", text: "shot gun").find(:xpath, "./following-sibling::section[contains(@class, 'properties')]/h3").click
  end

  And 'I should see "author" with value "Mr. Blake" for property "parts of speach"' do
    td = page.find(:xpath, "//*[contains(@class, 'term')]/*[contains(@class, 'value') and text() = 'shot gun']/following-sibling::*[@class = 'properties']//th[text() = 'parts of speach']/following-sibling::td")
    td.should have_css(".system-info th", text: "author")
    td.should have_css(".system-info td", text: "Mr. Blake")
  end
end
