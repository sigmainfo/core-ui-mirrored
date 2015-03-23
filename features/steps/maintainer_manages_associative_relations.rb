class Spinach::Features::MaintainerManagesAssociativeRelations < Spinach::FeatureSteps
  include AuthSteps
  include Resources
  include EditSteps

  step 'a "see also" defined relation' do
    @relations = [] unless @relations
    @relations << { key: 'see also', type: 'associative', icon: 'see_also.png' }
  end

  step 'the repository is configured with these relation(s)' do
    relation_types.put relation_types: { "": @relations }
  end

  step 'a concept with label "mobile phone" exists' do
    @concept_mobile = JSON.parse concepts.post concept: { properties: { "": [{key: 'label', value: 'mobile phone'}] } }
  end

  step 'a concept with label "cell phone" exists' do
    @concept_cell = JSON.parse concepts.post concept: { properties: { "": [{key: 'label', value: 'cell phone'}] } }
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

  step 'I visit the concept details page for "mobile phone"' do
    visit "/#{current_repository.id}/concepts/#{@concept_mobile['id']}"
  end

  step 'I search for "cell phone"' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "cell phone"
      find('input[type="submit"]').click
    end
  end

  step 'I click on the search result' do
    sleep 0.5
    expect(page).to have_css('.concept-list .concept-list-item a.concept-label')
    find(".concept-list a.concept-label").click
  end

  step 'I drag the concept label to the cliboard' do
    find(".concept-head h2.concept-label.ui-draggable").drag_to find("#coreon-clipboard ul")
  end

  step 'I visit the concept details page for "cell phone"' do
    visit "/#{current_repository.id}/concepts/#{@concept_cell['id']}"
  end

  step 'I click "Edit relations" within "ASSOCIATED" section' do
    @section = page.find :section, 'Associated'
    within @section do
      page.find('a', text: 'Edit relations').click
    end
  end

  step 'I drag the clipped concept to the "see also" dropzone' do
    @relations_list = @section.find ".relations ul"
    find("#coreon-clipboard a.concept-label.ui-draggable").drag_to @relations_list
  end

  step 'I should see "mobile phone" unsaved as associated relation' do
    within @relations_list do
      find "li .concept-label", text: "mobile phone"
    end
  end

  step 'I should see "cell phone" in the "see also" associated relation dropzone' do
    within @section do
      @see_also_dropzone = page.find "td.relations ul"
      @cell_label = find("a", text: "cell phone")
      expect(@cell_label).to be_visible
    end
  end

  step 'I drag the "cell phone" concept label just outside the "see also" dropzone' do
    @cell_label.drag_to find("tr.relation-type th")
  end

  step 'the "see also" dropzone should be empty' do
    expect(@see_also_dropzone).not_to have_css("a")
  end

  step 'I should see reset, cancel and save buttons' do
    @form = page.find ".concept.edit .associative-relations form"
    within @form do
      find(".submit .reset")
      find(".submit .cancel")
      find(".submit [type=submit]")
    end
  end

  step 'I click save' do
    within @form do
      click_link_or_button "Save"
    end
  end

  step 'I click cancel' do
    within @form do
      click_link_or_button "Cancel"
    end
  end

  step 'I click reset' do
    within @form do
      click_link_or_button "Reset"
    end
  end

  step 'I am no longer in "edit relations" mode' do
    within @section do
      expect(page).not_to have_css('form')
    end
  end

  step 'the concept "cell phone" displays "mobile phone" as a "see also" relation' do
    relation = page.find :table_row, 'see also'
    within relation do
      expect(relation).to have_css("a", text: "mobile phone")
    end
  end

  step 'this section has an empty "see also" relation' do
    relation = page.find :table_row, 'see also'
    within relation do
      expect(relation).not_to have_css("a")
    end
  end

  step 'this section does not have an "see also" relation area' do
    expect(page).not_to have_selector :table_row, 'see also'
  end

  step 'the concept "mobile phone" displays "cell phone" as a "see also" relation' do
    relation = page.find :table_row, 'see also'
    within relation do
      expect(relation).to have_css("a", text: "cell phone")
    end
  end

end
