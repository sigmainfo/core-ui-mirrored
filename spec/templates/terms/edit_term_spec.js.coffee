#= require spec_helper
#= require templates/terms/edit_term

describe 'Coreon.Templates[terms/edit_term]', ->

  template = Coreon.Templates['terms/edit_term']
  data = null

  beforeEach ->
    data =
      value: ''
      info: {}
      render: -> ''
      action_for: -> ''

  render = ->
    $('<div>').html(template data)

  context 'term', ->

    beforeEach ->
      @stub data, 'render'

    it 'renders nested template', ->
      data.value = 'dead'
      data.info = author: 'tc'
      data.render
        .withArgs('terms/term', value: 'dead', info: data.info)
        .returns '''
          <h4 class="value">dead</h4>
        '''
      el = render()
      expect(el).to.have 'h4.value'

  context 'edit actions', ->

    action_for = null

    beforeEach ->
      action_for = @stub data, 'action_for'

    editActions = (el) ->
      el.find '.edit-actions'

    it 'renders container', ->
      el = render()
      expect(editActions el).to.exist

    it 'renders action for removing term', ->
      action_for
        .withArgs('term.remove_term')
        .returns '<a class="remove-term" href="#">Remove term</a>'
      el = render()
      expect(editActions el).to.have 'a.remove-term'
