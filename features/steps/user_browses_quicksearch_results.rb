class UserBrowsesQuicksearchResults < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps
  include Api::Graph::Factory


  Given 'the following English terms: "dead", "man", "nobody", "poet", "poetic", "poetise", "poetize", "poetry", "train", "wild"' do
    %w|dead man nobody poet poetic poetise poetize poetry train wild|.each do |term|
      create_term term, "en"
    end
  end

  And 'given the following German terms: "poetisch", "dichterisch", "Dichtkunst"' do
    %w|poetisch dichterisch Dichtkunst|.each do |term|
      create_term term, "de"
    end
  end

  And 'a concept with id "50005aece3ba3f095c000001" that contains the terms "poetize" and "poetise"' do
    term1 = Api::Graph::Term.find_by value: "poetize"
    term2 = Api::Graph::Term.find_by value: "poetise"
    concept = Api::Graph::Concept.create!
    concept.id = "50005aece3ba3f095c000001"
    concept.save!
    concept.properties.create! key: "label", value: "versify"
    concept.save!
    term1.concept = concept
    term1.save!
    term2.concept = concept
    term2.save!
  end

  And 'I should see a listing "TERMS"' do
    page.should have_css(".search-results-terms h3", text: "TERMS")
  end

  And 'the listing should contain "poet", "poetic", "poetisch", "poetise", "poetize", "poetry"' do
    sleep 0.3
    page.all(".terms tbody td:first").map(&:text).should == %w|poet poetic poetisch poetise poetize poetry|
  end

  And '"poetic" should have language "EN"' do
    page.find("td", text: "poetic").find(:xpath, "following::td").text.should == "EN"
  end

  And '"poetisch" should have language "DE"' do
    page.find("td", text: "poetisch").find(:xpath, "following::td").text.should == "DE"
  end

  And '"poetize" should have concept "50005aece3ba3f095c000001"' do
    page.find("td", text: "poetize").all(:xpath, "following::td")[1].text.should == "50005aece3ba3f095c000001"
  end

  When 'I click on link to concept "50005aece3ba3f095c000001"' do
    click_link "50005aece3ba3f095c000001"
  end

  Then 'I should be on the page of concept "50005aece3ba3f095c000001"' do
    current_path.should == "/concepts/50005aece3ba3f095c000001"
  end

  Given 'the a concept with id "50005aece3ba3f095c000001" and label "dead"' do
    create_concept_with_id "50005aece3ba3f095c000001", label: "dead"
  end

  And 'given a concept with id "50005aece3ba3f095c000002" and label "versify"' do
    @concept = create_concept_with_id "50005aece3ba3f095c000002", label: "versify"
  end

  And 'that concept has the English term "poetize"' do
    @concept.terms.create! value: "poetize", lang: "en"
  end

  And 'given a concept with id "50005aece3ba3f095c000003" and label "poet"' do
    create_concept_with_id "50005aece3ba3f095c000003", label: "poet"
  end

  And 'given a concept with id "50005aece3ba3f095c000004" and label "poem"' do
    @poem = create_concept_with_id "50005aece3ba3f095c000004", label: "poem"
  end

  And 'given a concept with id "50005aece3ba3f095c000005" and label "poetry"' do
    @poetry = create_concept_with_id "50005aece3ba3f095c000005", label: "poetry"
  end

  And '"poem" is a subconcept of "poetry"' do
    @poetry.sub_concepts << @poem
    @poetry.save!
  end

  And 'I should see a listing "CONCEPTS"' do
    page.should have_css(".search-results-concepts h3", text: "CONCEPTS")
  end

  And 'the listing should contain "poet", "poem", "poetry", "versify"' do
    sleep 0.2
    page.all(".concepts tbody td.label").map(&:text).should == %w|poet poem poetry versify|
  end

  And '"poem" should have id "50005aece3ba3f095c000004"' do
    page.find("td", text: "poem").find(:xpath, "following::td[@class='id']").text.should == "50005aece3ba3f095c000004"
  end

  And '"poem" should have superconcept "poetry"' do
    page.find("td", text: "poem").find(:xpath, "following::td[contains(@class, 'super')]").text.should == "poetry"
  end

  When 'I click on link to concept "poetry"' do
    page.find("a.concept-label", text: "poetry").click
  end

  Then 'I should be on the concept page of "poetry"' do
    current_path.should == "/concepts/#{@poetry.id}"
  end

  Given 'a taxonomy "Professions"' do
    @professions = Api::Graph::Taxonomy.create! name: "Professions"
  end

  And 'this taxonomy has a node "programmer"' do
    @professions.nodes.create! name: "programmer"
  end

  And 'this taxonomy has a node "artist"' do
    @artist = @professions.nodes.create! name: "artist"
  end

  And 'this taxonomy has a node "poet"' do
    @poet = @professions.nodes.create! name: "poet"
  end

  And '"poet" is a subnode of "artist"' do
    @artist.sub_nodes << @poet
    @artist.save!
  end

  And 'this taxonomy has a node "poetry editor"' do
    @professions.nodes.create! name: "poetry editor"
  end

  And 'I should see a listing "TAXONOMIES"' do
    page.should have_css(".search-results-tnodes h3", text: "TAXONOMIES")
  end

  And 'the listing should contain "poet", "poetry editor", "artist"' do
    sleep 0.2
    page.all(".tnodes tbody td.name").map(&:text).should == ["poet", "poetry editor", "artist"]
  end
end
