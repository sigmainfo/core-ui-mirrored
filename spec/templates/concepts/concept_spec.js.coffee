#= require spec_helper
#= require templates/concepts/concept

describe 'Coreon.Templates[concepts/concept]', ->

  template = Coreon.Templates['concepts/concept']

  data = null
  concept = null
  conceptData = null

  buildConcept = ->
    concept = new Backbone.Model
    concept.info = -> []
    concept

  buildConceptData = ->
    id: ''
    label: ''
    info: {}

  render = ->
    $('<div>').html(template data)

  beforeEach ->
    concept = buildConcept()
    conceptData = buildConceptData()
    data =
      model: concept
      concept: conceptData
      langs: []

      editing: no

      render: -> ''
      can: -> no
      action_for: -> ''

  context 'head', ->

    head = (el) -> el.find '.concept-head'

    it 'renders head division', ->
      el = render()
      expect(head el).to.exist

    context 'edit', ->

      can = null
      action_for = null

      beforeEach ->
        can = @stub data, 'can'
        action_for = @stub data, 'action_for'

      context 'with maintainer privileges', ->

        beforeEach ->
          can.withArgs('manage').returns yes

        it 'renders edit mode toggle', ->
          action_for.withArgs('concept.toggle_edit_mode')
            .returns '<a class="toggle-edit-mode">Edit mode</a>'
          el = render()
          expect(head el).to.have 'a.toggle-edit-mode'

        it 'renders delete action', ->
          action_for.withArgs('concept.delete_concept')
            .returns '<a class="delete-concept">Delete concept</a>'
          el = render()
          edit = head(el).find('.edit-actions')
          expect(edit).to.have 'a.delete-concept'

      context 'without maintainer privileges', ->

        beforeEach ->
          can.withArgs('manage').returns no

        it 'does not render edit mode toggle', ->
          action_for.withArgs('concept.toggle_edit_mode')
            .returns '<a class="toggle-edit-mode">Edit mode</a>'
          el = render()
          expect(head el).to.not.have '.toggle-edit-mode'

        it 'does not render edit division', ->
          el = render()
          expect(head el).to.not.have '.edit-actions'

    context 'actions', ->

      action_for = null

      actions = (el) ->
        head(el).find '.actions'

      beforeEach ->
        action_for = @stub data, 'action_for'

      it 'renders actions division', ->
        el = render()
        expect(actions el).to.exist

      it 'renders add-to-clipbaord action', ->
        action_for.withArgs('concept.add_to_clipboard')
          .returns '<a class="add-to-clipboard">Add to clipboard</a>'
        el = render()
        expect(actions el).to.have 'a.add-to-clipboard'

      it 'renders remove-from-clipbaord action', ->
        action_for.withArgs('concept.remove_from_clipboard')
          .returns '<a class="remove-from-clipboard">Remove from clipboard</a>'
        el = render()
        expect(actions el).to.have 'a.remove-from-clipboard'

      it 'renders toggle-system-info action', ->
        action_for.withArgs('concept.toggle_system_info')
          .returns '<a class="toggle-system-info">Toggle system info</a>'
        el = render()
        expect(actions el).to.have 'a.toggle-system-info'

    context 'label', ->

      beforeEach ->
        @stub data, 'render'

      it 'renders caption', ->
        _(conceptData).extend
          id: 'c123'
          label: 'My Concept'
        data.render
          .withArgs('concepts/caption', label: 'My Concept', dragId: 'c123')
          .returns '<h2 class="concept-label">My Concept</h2>'
        el = render()
        expect(head el).to.have 'h2.concept-label'

    context 'system info', ->

      beforeEach ->
        @stub data, 'render'

      it 'renders table', ->
        conceptData.info = created_at: '2014-05-05'
        data.render.withArgs('shared/info', data: created_at: '2014-05-05')
          .returns '''
            <table class="system-info">
              <tr>
                <th>created_at</th>
                <td>1014-05-05</td>
              </tr>
            </table>
          '''
        el = render()
        expect(head el).to.have 'table.system-info'

  context 'properties', ->

    context 'edit', ->

      beforeEach ->
        @stub data, 'render'
        data.editing = on
        data.render
          .withArgs('concepts/edit_properties')
          .returns '''
            <form class="edit-properties" action="javascript:void(0)">
              <input type="submit">
            </form>
          '''

      context 'editing properties', ->

        beforeEach ->
          data.editProperties = on

        it 'renders form', ->
          data.render
            .withArgs('concepts/edit_properties' , concept: concept)
            .returns '''
              <form class="edit-properties" action="javascript:void(0)">
                <input type="submit">
              </form>
            '''
          el = render()
          expect(el).to.have 'form.edit-properties'

      context 'editing other', ->

        beforeEach ->
          data.editProperties = off

        it 'does not render form', ->
          el = render()
          expect(el).to.not.have '.edit-properties'

    context 'show', ->

      beforeEach ->
        data.editing = on

      it 'does not render form', ->
        el = render()
        expect(el).to.not.have '.edit-properties'
