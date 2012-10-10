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

  Given 'a concept with id "50005aece3ba3f095c000001" and label "handgun"' do
    @handgun = create_concept_with_id "50005aece3ba3f095c000001", label: "handgun"
  end

  And 'this concept has an English definition with value "A portable firearm"' do
    @handgun.properties.create! key: "definition", value: "A portable firearm", lang: "en"
  end

  And 'this concept has an German definition with value "Tragbare Feuerwaffe"' do
    @handgun.properties.create! key: "definition", value: "Tragbare Feuerwaffe", lang: "de"
  end

  And 'this concept has a property "notes" with value "Bitte überprüfen!!!"' do
    @handgun.properties.create! key: "notes", value: "Bitte überprüfen!!!"
  end

  And 'this concept has the following English terms: "gun", "firearm", "shot gun", "musket"' do
    ["gun", "firearm", "shot gun", "musket"].each do |value|
      @handgun.terms.create! value: value, lang: "en"
    end
  end

  And 'this concept has the following German terms: "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"' do
    ["Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"].each do |value|
      @handgun.terms.create! value: value, lang: "de"
    end
  end

  And 'the term "Schusswaffe" should have property "gender" with value "f"' do
    term = @handgun.terms.find_by value: "Schusswaffe"
    term.properties.create! key: "gender", value: "f"
  end

  And 'given a broader concept with id "50005aece3ba3f095c000004" and a label "weapon"' do
    weapon = create_concept_with_id "50005aece3ba3f095c000004", label: "weapon"
    @handgun.super_concepts << weapon
    @handgun.save!
  end

  And 'given a narrower concept with id "50005aece3ba3f095c000002" and a label "pistol"' do
    pistol = create_concept_with_id "50005aece3ba3f095c000002", label: "pistol"
    @handgun.sub_concepts << pistol
    @handgun.save!
  end

  And 'given a narrower concept with id "50005aece3ba3f095c000005" and a label "revolver"' do
    revolver = create_concept_with_id "50005aece3ba3f095c000005", label: "revolver"
    @handgun.sub_concepts << revolver
    @handgun.save!
  end

  And 'I click on the label "handgun"' do
    page.find(".concepts a.concept-label", text: "handgun").click
  end

  Then 'I should be on the show concept page for id "50005aece3ba3f095c000001"' do
    current_path.should == "/concepts/50005aece3ba3f095c000001"
  end

  And 'I should see the label "handgun"' do
    page.find(".concept .label").should have_content("handgun")
  end

  And 'I should see id "50005aece3ba3f095c000001"' do
    page.find(".concept .id").should have_content("50005aece3ba3f095c000001")
  end

  And 'I should see the section "Broader & Narrower"' do
    page.should have_css("h3.section-toggle", text: "Broader & Narrower")
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

  And 'I should see the section "Properties"' do
    page.should have_css("h3.section-toggle", text: "Properties")
  end

  And 'it should have an English property "definition" with value "A portable firearm"' do
    @td = page.find("th", text: "definition").find :xpath, "parent::*/td"
    @td.find("ul.index li.selected").text.should == "en"
    @td.find("ul.values li").text.should == "A portable firearm"
  end

  When 'I click on "de" for that property' do
    @td.find("ul.index li a", text: "de").click
  end

  Then 'the value should have changed to "Tragbare Feuerwaffe"' do
    @td.find("ul.values li").text.should == "Tragbare Feuerwaffe"
  end

  And 'it should have a property "notes" with value "Bitte überprüfen!!!"' do
    @td = page.find("th", text: "notes").find :xpath, "parent::*/td"
    @td.text.should == "Bitte überprüfen!!!"
  end

  And 'I should see a section for locale "en"' do
    page.should have_css("h3.section-toggle", text: "en")
    @lang = page.find :xpath, "//h3[contains(@class, 'section-toggle') and text()='en']/following-sibling::div[contains(@class, 'section')]"
  end

  And 'it shoud have the following terms "gun", "firearm", "shot gun", "musket"' do
    ["gun", "firearm", "shot gun", "musket"].each do |term|
      @lang.should have_content(term)
    end
  end

  And 'I should see a section for locale "de"' do
    page.should have_css("h3.section-toggle", text: "de")
    @lang = page.find :xpath, "//h3[contains(@class, 'section-toggle') and text()='de']/following-sibling::div[contains(@class, 'section')]"
  end

  And 'it shoud have the following terms "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"' do
    ["Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"].each do |term|
      @lang.should have_content(term)
    end
  end

  When 'I click on toggle "Properties" of term "Schusswaffe"' do
    page.find(:xpath, "//*[contains(@class, 'value') and text() = 'Schusswaffe']/following-sibling::*[contains(@class, 'properties')]/*[contains(@class, 'section-toggle')]").click
  end

  Then 'I should see property "gender" with value "f"' do
    page.should have_css(".term .properties th", text: "gender")
    page.find(:xpath, "//th[text() = 'gender']/following-sibling::td").text.should == "f"
  end

  When 'I click on the toggle of the locale "en"' do
    click_on_toggle "en"
  end

  Then 'the locale should be hidden' do
    section_for("en").should_not be_visible
  end

  Then 'I should see the term "gun"' do
    page.should have_css(".term .value", text: "gun")
  end

  When 'I click on the toggle "Broader & Narrower"' do
    page.execute_script "$('.notification .hide').click()"
    click_on_toggle "Broader & Narrower"
  end

  Then 'the concept tree should be hidden' do
    section_for("Broader & Narrower").should_not be_visible
  end

  When 'I click on the toggle "Properties"' do
    click_on_toggle "Properties"
  end

  Then 'the concept properties should be hidden' do
    section_for("Properties").should_not be_visible
  end
end
