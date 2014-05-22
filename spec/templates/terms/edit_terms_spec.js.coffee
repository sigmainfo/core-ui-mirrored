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
      render: @stub()

  render = ->
    $('<div>').html(template data)

  context 'languages', ->

    it 'inserts language sections from show template', ->
      lang = id: 'el'
      data.languages = [lang]
      data.render
        .withArgs('terms/terms', languages: [lang])
        .returns '<section class="lang en"></section>'
      el = render()
      expect(el).to.have 'section.en'
