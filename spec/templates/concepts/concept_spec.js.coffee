#= require spec_helper
#= require templates/concepts/concept

describe 'Coreon.Templates[concepts/concept]', ->

  template = Coreon.Templates['concepts/concept']

  data = null
  concept = null

  buildConcept = ->
    concept = new Backbone.Model
    concept.info = -> []
    concept

  render = ->
    $('<div>').html(template data)

  beforeEach ->
    sinon.stub I18n, 't'

    concept = buildConcept()

    data =
      render: -> ''
      can: -> no
      action_for: -> ''
      concept: concept

  afterEach ->
    I18n.t.restore()

  context 'head', ->

    it 'renders head division', ->
      el = render()
      expect(el).to.have '.concept-head'

    context 'edit', ->

      can = null
      action_for = null

      beforeEach ->
        can = sinon.stub data, 'can'
        action_for = sinon.stub data, 'action_for'

      context 'with maintainer privileges', ->

        beforeEach ->
          can.withArgs('manage').returns yes

        it 'renders edit mode toggle', ->
          action_for.withArgs('concept.toggle_edit_mode', className: 'button')
            .returns '<a class="toggle-edit-mode">Edit mode</a>'
          el = render()
          head = el.find('.concept-head')
          expect(head).to.have 'a.toggle-edit-mode'

        it 'renders delete action', ->
          action_for.withArgs('concept.delete_concept')
            .returns '<a class="delete-concept">Delete concept</a>'
          el = render()
          edit = el.find('.concept-head .edit')
          expect(edit).to.have 'a.delete-concept'

      context 'without maintainer privileges', ->

        beforeEach ->
          can.withArgs('manage').returns no

        it 'does not render edit mode toggle', ->
          action_for.withArgs('concept.toggle_edit_mode', className: 'button')
            .returns '<a class="toggle-edit-mode">Edit mode</a>'
          el = render()
          head = el.find('.concept-head')
          expect(head).to.not.have '.toggle-edit-mode'

        it 'does not render edit division', ->
          el = render()
          head = el.find('.concept-head')
          expect(head).to.not.have '.edit'
