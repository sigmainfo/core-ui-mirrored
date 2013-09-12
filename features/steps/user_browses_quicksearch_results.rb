class UserBrowsesQuicksearchResults < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps
  include Api::Graph::Factory


  Given 'the following English terms: "dead", "man", "nobody", "poet", "poetic", "poetry", "train", "wild"' do
    @concept = create_concept({})
    %w|dead man nobody poet poetic poetry train wild|.each do |term|
      create_concept_term @concept, value: term, lang: "en"
    end
  end

  And 'given the following German terms: "poetisch", "dichterisch", "Dichtkunst"' do
    %w|poetisch dichterisch Dichtkunst|.each do |term|
      create_concept_term @concept, value: term, lang: "de"
    end
  end

  And 'a concept "versify" that contains the terms "poetize" and "poetise"' do
    @versify = create_concept({
      properties: [
        {key: "label", value: "versify"}
      ],
      terms: [
        {value: "poetize", lang: 'en'},
        {value: "poetise", lang: 'en'},
      ]
    })
  end

  And 'I should see a listing "TERMS"' do
    page.should have_css(".search-results-terms h3", text: "TERMS")
  end

  And 'the listing should contain "poet", "poetic", "poetisch", "poetise", "poetize", "poetry"' do
    sleep 0.3
    page.all(".terms tbody td:first-child").map(&:text).should == [ "poet", "poetisch", "poetic", "poetry", "poetize", "poetise" ]
  end

  And '"poetic" should have language "EN"' do
    page.find("td", text: "poetic").find(:xpath, "following-sibling::td[1]").text.should == "EN"
  end

  And '"poetisch" should have language "DE"' do
    page.find("td", text: "poetisch").find(:xpath, "following-sibling::td[1]").text.should == "DE"
  end

  And '"poetize" should have concept "versify"' do
    page.find("td", text: "poetize").find(:xpath, "following-sibling::td[2]").text.should == "versify"
  end

  When 'I click on link to concept "versify"' do
    page.find(".search-results-concepts a.concept-label", text: "versify").click
  end

  Then 'I should be on the page of concept "versify"' do
    current_path.should == "/#{@repository.id}/concepts/#{@versify['id']}"
  end

  Given 'the a concept with label "dead"' do
    create_concept properties: [{key: 'label', value: "dead"}]
  end

  And 'given a concept with label "versify"' do
    @concept = create_concept properties: [{key: 'label', value: "versify"}]
  end

  And 'that concept has the English term "poetize"' do
    create_concept_term @concept, value: "poetize", lang: "en"
  end

  And 'given a concept with label "poet"' do
    @poet = create_concept properties: [{key: 'label', value: "poet"}]
  end

  And 'given a concept with label "poem"' do
    @poem = create_concept properties: [{key: 'label', value: "poem"}]
  end

  And 'given a concept with label "poetry"' do
    @poetry = create_concept properties: [{key: 'label', value: "poetry"}]
  end

  And '"poet" is a subconcept of "poetry"' do
    create_edge({
      source_node_type: 'Concept', 
      source_node_id: @poetry['id'],
      edge_type: 'SUPERCONCEPT_OF',
      target_node_type: 'Concept',
      target_node_id: @poet['id']
    })
  end

  And 'I should see a listing "CONCEPTS"' do
    page.should have_css(".search-results-concepts h3", text: "CONCEPTS")
  end

  And 'the listing should contain "poet", "versify", "poetry"' do
    sleep 0.2
    page.all(".concepts tbody td.label").map(&:text).should == %w|poet versify poetry|
  end

  And '"poem" should have the correct id' do
    page.find("td", text: "poem").find(:xpath, "following-sibling::td[1][@class='id']").text.should == "50005aece3ba3f095c000004"
  end

  And '"poet" should have superconcept "poetry"' do
    page.find(".search-results-concepts td", text: /^poet$/).find(:xpath, "following-sibling::td[1][contains(@class, 'super')]").text.should == "poetry"
  end

  When 'I click on link to concept "poetry"' do
    page.find(".search-results-concepts td.label a.concept-label", text: "poetry").click
  end

  Then 'I should be on the concept page of "poetry"' do
    current_path.should == "/#{@repository.id}/concepts/#{@poetry['id']}"
  end

  Given 'a taxonomy "Professions"' do
    @professions = create_taxonomy properties: [{key: "label", value: "Professions"}]
  end

  And 'this taxonomy has a node "programmer"' do
    @programmer = create_taxonomy_taxonomy_node @professions, properties: [{key: "label", value: "programmer"}]
  end

  And 'this taxonomy has a node "artist"' do
    @artist = create_taxonomy_taxonomy_node @professions, properties: [{key: "label", value: "artist"}]
  end

  And 'this taxonomy has a node "poet"' do
    @poet = create_taxonomy_taxonomy_node @professions, properties: [{key: "label", value: "poet"}]
  end

  And '"poet" is a subnode of "artist"' do
    create_edge({
      source_node_type: 'TaxonomyNode', 
      source_node_id: @artist['id'],
      edge_type: 'SUPERNODE_OF',
      target_node_type: 'TaxonomyNode',
      target_node_id: @poet['id']
    })
  end

  And 'this taxonomy has a node "poetry editor"' do
    create_taxonomy_taxonomy_node @professions, properties: [{key: "label", value: "poetry editor"}]
  end

  And 'I should see a listing "TAXONOMIES"' do
    page.should have_css(".search-results-tnodes h3", text: "TAXONOMIES")
  end

  And 'the listing should contain "poet", "poetry editor"' do
    sleep 0.2
    page.all(".tnodes tbody td.name").map(&:text).should == ["poet", "poetry editor"]
  end
end
