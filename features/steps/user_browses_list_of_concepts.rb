# encoding: utf-8

require 'uri'

class UserBrowsesListOfConcepts < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps
  include Api::Graph::Factory

  def find_concept(label)
    @concept = page.find(".concept-list-item .label", text: label).find :xpath, "ancestor::*[contains(@class, 'concept-list-item')]"
  end

  Given 'a concept with id "50005aece3ba3f095c000001" defined as "A portable firearm"' do
    @handgun = create_concept_with_id "50005aece3ba3f095c000001", definition: "A portable firearm"
  end

  And 'this concept has the label "handgun"' do
    @handgun.properties.create! key: "label", value: "handgun"
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

  And 'given another concept with id "50005aece3ba3f095c000002" defined as "a handgun whose chamber is integral with the barrel;"' do
    @pistol = create_concept_with_id "50005aece3ba3f095c000002", definition: "a handgun whose chamber is integral with the barrel;"
  end

  And 'this concept has the following English terms: "pistol", "gun", "automatic pistol"' do
    ["pistol", "gun", "automatic pistol"].each do |value|
      @pistol.terms.create! value: value, lang: "en"
    end
  end

  And 'this concept is a subconcept of "handgun"' do
    @handgun.sub_concepts << @pistol
    @handgun.save!
  end

  And 'I click "Show all" within the concept search results' do
    within ".search-results-concepts" do
      click_link "Show all"
    end
  end

  Then 'I should be on the search result page for concepts' do
    current_path.should == "/concepts/search"
  end

  And 'I should see a concept "handgun"' do
    @concept = find_concept("handgun")
  end

  And 'I should see it being defined as "A portable firearm"' do
    @concept.find(".definition").should have_content("A portable firearm")
  end

  And 'I should see it having the following English terms: "gun", "firearm", "shot gun", "musket"' do
    @concept.find(".terms th", text: "EN").find(:xpath, "../td").should have_content("gun, firearm, shot gun, musket")
  end

  And 'I should see it having the following German terms: "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"' do
    @concept.find(".terms th", text: "DE").find(:xpath, "../td").should have_content("Schusswaffe, Flinte, Pistole, Schießgewehr, Geschütz")
  end

  And 'I should see a concept "pistol"' do
    @concept = find_concept("pistol")
  end

  And 'I should see it being narrower than "handgun"' do
    @concept.find(".super").should have_content("handgun")
  end

  When 'I select "Concepts by Terms" as the type of search' do
    page.find("#coreon-search-target-select .toggle").click
    page.find("li.option", text: "Concepts by Terms").click
  end

  And 'the target should be "terms"' do
    URI.parse(current_url).query.should =~ /\bt=terms\b/
  end

  And 'the query should be "gun"' do
    URI.parse(current_url).query.should =~ /\bq=gun\b/
  end

  When 'I select "Concepts by Definition" as the type of search' do
    page.find("#coreon-search-target-select .toggle").click
    page.find("li.option", text: "Concepts by Definition").click
  end

  And 'the target should be "definition"' do
    URI.parse(current_url).query.should =~ /\bt=definition\b/
  end
end
