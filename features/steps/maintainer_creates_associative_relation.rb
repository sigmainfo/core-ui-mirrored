class Spinach::Features::MaintainerCreatesAssociativeRelation < Spinach::FeatureSteps
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

  step 'I click "Edit relations" within "ASSOCIATIVE RELATIONS" section' do
    @section = page.find :section, 'Associative Relations'
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

end
