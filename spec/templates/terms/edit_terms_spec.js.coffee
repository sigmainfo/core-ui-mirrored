#= require spec_helper
#= require templates/terms/edit_terms

describe 'Coreon.Templates[terms/edit_terms]', ->

  template = Coreon.Templates['terms/edit_terms']
  data = null
  languages = null

  beforeEach ->
    languages = [['en', ]]
    data =
      languages: []
      render: -> ''
      action_for: -> ''

  render = ->
    $('<div>').html(template data)

  context 'edit actions', ->

    it 'renders action for adding a term', ->
      @stub(data, 'action_for')
        .withArgs('terms.add_term')
        .returns '<a class="add-term" href="#">Add term</a>'
      el = render()
      expect(el).to.have 'a.add-term'

  context 'languages', ->

    it 'inserts language sections from show template', ->
      lang = id: 'el'
      data.languages = [lang]
      @stub(data, 'render')
        .withArgs('terms/terms', languages: [lang])
        .returns '<section class="lang en"></section>'
      el = render()
      expect(el).to.have 'section.en'
