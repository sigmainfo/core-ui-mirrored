class Spinach::Features::UserBrowsesConceptMapInSourceAndTargetLanguage < Spinach::FeatureSteps
  include AuthSteps
  include LanguageSelectSteps
  include Api::Graph::Factory
  include Selectors

  def label(node)
    node.find('text').text()
  end

  step 'a concept with English term "gun" and German term "Flinte"' do
    @concept = create_concept terms: [
      {lang: 'en', value: 'gun'},
      {lang: 'de', value: 'Flinte'}
    ]
  end

  step 'I visit the concept details page' do
    visit "/#{current_repository.id}/concepts/#{@concept['id']}"
  end

  step 'no source or target language is selected' do
    select_source_lang :none
    select_target_lang :none
  end

  step 'I should see a single node inside the concept map' do
    within concept_map do
      concept_nodes = page.all '.concept-node:not(.repository-root)'
      expect(concept_nodes.count).to eq(1)
      @node = concept_nodes.first
    end
  end

  step 'the label of the node should read "gun"' do
    expect(label @node).to eq('gun')
  end

  step 'the label of the node should read "Flinte"' do
    expect(label @node).to eq('Flinte')
  end
end
