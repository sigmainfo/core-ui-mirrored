# encoding: utf-8

require 'uri'

class UserBrowsesListOfConcepts < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps
  include Api::Graph::Factory
  include LanguageSelectSteps

  def find_concept(label)
    @concept = page.find(".concept-list-item .label", text: label).find :xpath, "ancestor::*[contains(@class, 'concept-list-item')]"
  end

  Given 'a concept defined as "A portable firearm"' do
    @handgun = create_concept properties: [{key: 'definition', value: 'A portable firearm'}]
  end

  And 'this concept has the label "handgun"' do
    create_concept_property @handgun, key: "label", value: "handgun"
  end

  And 'this concept has the following English terms: "gun", "firearm", "shot gun", "musket"' do
    ["gun", "firearm", "shot gun", "musket"].each do |value|
      create_concept_term @handgun, value: value, lang: "en"
    end
  end

  And 'this concept has the following German terms: "Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"' do
    ["Schusswaffe", "Flinte", "Pistole", "Schießgewehr", "Geschütz"].each do |value|
      create_concept_term @handgun, value: value, lang: "de"
    end
  end

  And 'given another concept defined as "a handgun whose chamber is integral with the barrel;"' do
    @pistol = create_concept properties: [{key: 'definition', value: 'a handgun whose chamber is integral with the barrel;'}]
  end

  And 'this concept has the following English terms: "pistol", "gun", "automatic pistol"' do
    ["pistol", "gun", "automatic pistol"].each do |value|
      create_concept_term @pistol, value: value, lang: "en"
    end
  end

  And 'this concept is a subconcept of "handgun"' do
    create_edge({
      source_node_type: 'Concept',
      source_node_id: @handgun['id'],
      edge_type: 'SUPERCONCEPT_OF',
      target_node_type: 'Concept',
      target_node_id: @pistol['id']
    })
  end

  step 'I should be on the search result page for concepts with query "gun"' do
    page.should have_css("#coreon-main .concept-list")
    current_path.should == "/#{current_repository.id}/concepts/search/gun"
  end

  And 'I should see a concept "handgun"' do
    @concept = find_concept("handgun")
  end

  And 'I should see it being defined as "A portable firearm"' do
    @concept.find(".definition").should have_content("A portable firearm")
  end

  And 'I should see it having the following English terms: "firearm", "gun", "musket", "shot gun"' do
    @concept.find(".lang th", text: "EN").find(:xpath, "../td").should have_content("firearm | gun | musket | shot gun")
  end

  And 'I should see it having the following German terms: "Flinte", "Geschütz", "Pistole", "Schießgewehr", "Schusswaffe"' do
    @concept.find(".lang th", text: "DE").find(:xpath, "../td").should have_content("Flinte | Geschütz | Pistole | Schießgewehr | Schusswaffe")
  end

  And 'I should see a concept "pistol"' do
    @concept = find_concept("pistol")
  end

  And 'I should see it being narrower than "handgun"' do
    @concept.find(".broader").should have_content("handgun")
  end

  When 'I select "Concepts by Terms" as the type of search' do
    sleep 0.5
    page.find("#coreon-search-target-select .toggle").click
    page.find("li.option", text: "Concepts by Terms").click
  end

  step 'I should be on the search result page for concepts with target "terms" and query "gun"' do
    current_path.should == "/#{current_repository.id}/concepts/search/terms/gun"
  end

  When 'I select "Concepts by Definition" as the type of search' do
    sleep 0.5
    page.find("#coreon-search-target-select .toggle").click
    page.find("li.option", text: "Concepts by Definition").click
  end

  step 'I should be on the search result page for concepts with target "definition" and query "gun"' do
    current_path.should == "/#{current_repository.id}/concepts/search/definition/gun"
  end
end
