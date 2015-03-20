class Spinach::Features::UserBrowsesAssociativeRelations < Spinach::FeatureSteps
  include AuthSteps
  include Resources

  step 'a "see also" defined relation' do
    @relations = [] unless @relations
    @relations << { key: 'see also', type: 'associative', icon: 'see_also.png' }
  end

  step 'an "antonymic" defined relation' do
    @relations = [] unless @relations
    @relations << { key: 'antonymic', type: 'associative', icon: 'antonymic.png' }
  end

  step 'the repository is configured with these relations' do
    relation_types.put relation_types: { "": @relations }
  end

  step 'a concept with label "mobile phone" exists' do
    @concept_mobile = JSON.parse concepts.post concept: { properties: { "": [{key: 'label', value: 'mobile phone'}] } }
  end

  step 'a concept with label "cell phone" exists' do
    @concept_cell = JSON.parse concepts.post concept: { properties: { "": [{key: 'label', value: 'cell phone'}] } }
  end

  step 'a concept with label "landline phone" exists' do
    @concept_landline = JSON.parse concepts.post concept: { properties: { "": [{key: 'label', value: 'landline phone'}] } }
  end

  step '"mobile phone" concept has a "see also" relation with concept "cell phone"' do
    edges.post edge: {
      source_node_type: 'Concept',
      source_node_id: @concept_mobile['id'],
      edge_type: 'see also',
      target_node_type: 'Concept',
      target_node_id: @concept_cell['id']
    }
  end

  step '"mobile phone" concept has an "antonymic" relation with concept "landline phone"' do
    edges.post edge: {
      source_node_type: 'Concept',
      source_node_id: @concept_mobile['id'],
      edge_type: 'antonymic',
      target_node_type: 'Concept',
      target_node_id: @concept_landline['id']
    }
  end

  step 'I visit the concept details page for "mobile phone"' do
    visit "/#{current_repository.id}/concepts/#{@concept_mobile['id']}"
  end

  step 'I see a section "ASSOCIATED"' do
    section = page.find :section, 'Associated'
    expect(section).to be_visible
  end

  step 'this section displays "cell phone" as a "see also" relation' do
    relation = page.find :table_row, 'see also'
    within relation do
      @cell_phone_label = find "a", text: "cell phone"
      expect(@cell_phone_label).to be_visible
    end
  end

  step 'this section displays "mobile phone" as a "see also" relation' do
    relation = page.find :table_row, 'see also'
    within relation do
      @mobile_phone_label = find "a", text: "mobile phone"
      expect(@mobile_phone_label).to be_visible
    end
  end

  step 'this section displays "landline phone" as an "antonymic" relation' do
    relation = page.find :table_row, 'antonymic'
    within relation do
      expect(page).to have_css("a", text: "landline phone")
    end
  end

  step 'I click on the "cell phone" relation label' do
    @cell_phone_label.click()
  end

  step 'I click on the "mobile phone" relation label' do
    @mobile_phone_label.click()
  end

  step 'I am directed to the "cell phone" concept page' do
    label = page.find(".concept.show .concept-head h2.concept-label")
    expect(label).to have_content("cell phone")
  end

  step 'I am directed to the "mobile phone" concept page' do
    label = page.find(".concept.show .concept-head h2.concept-label")
    expect(label).to have_content("mobile phone")
  end

  step 'this section has an empty "see also" relation' do
    relation = page.find :table_row, 'see also'
    within relation do
      expect(page).not_to have_css("a")
    end
  end

  step 'this section has an empty "antonymic" relation' do
    relation = page.find :table_row, 'antonymic'
    within relation do
      expect(page).not_to have_css("a")
    end
  end

  step 'I click the toggle "System Info" on the concept' do
    page.find(".concept .system-info-toggle", text: "System Info").click
  end

  step 'I do not see a table with system information about the relation' do
    relation = page.find :table_row, 'see also'
    within relation do
      expect(page).not_to have_css("li .system-info")
    end
  end

  step 'I see a table with system information about the relation' do
    relation = page.find :table_row, 'see also'
    within relation do
      expect(page).to have_css("li .system-info")
    end
  end

end
