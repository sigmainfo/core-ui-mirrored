#= require spec_helper
#= require templates/terms/terms
#= require templates/helpers/action_for

describe 'Coreon.Templates[terms/terms]', ->

  template = Coreon.Templates['terms/terms']
  action_for = null
  data = null

  render = ->
    $('<div>').html(template data)

  beforeEach ->
    action_for = @stub().returns ''
    data =
      languages: []
      action_for: action_for

  context 'actions', ->

    it 'renders properties toggle', ->
      action_for
        .withArgs('terms.toggle_all_properties')
        .returns '<a class="toggle-all-properties" href="#">Toggle all</a>'
      el = render()
      expect(el).to.have 'a.toggle-all-properties'

  context 'language sections', ->

    language = null

    beforeEach ->
      data.languages = [
        id: 'de-AT'
        className: 'de'
        empty: no
      ]
      language = data.languages[0]

    it 'renders section', ->
      language.id = 'de-AT'
      language.className = 'de'
      el = render()
      section = el.find('section')
      expect(section).to.exist
      expect(section).to.have.class 'language'
      expect(section).to.have.class 'de'
      expect(section).to.have.attr 'data-id', 'de-AT'

    it 'renders caption', ->
      language.id = 'el'
      el = render()
      section = el.find('section')
      caption = section.find('h3')
      expect(caption).to.exist
      expect(caption).to.have.text 'el'

    it 'renders empty list container', ->
      language.empty = no
      el = render()
      section = el.find('section')
      ul = section.find('ul')
      expect(ul).to.exist
      children = ul.children()
      expect(children).to.have.lengthOf 0

    it 'renders placeholder text when empty', ->
      language.empty = yes
      I18n.t.withArgs('terms.empty').returns '[No terms]'
      el = render()
      section = el.find('section')
      ul = section.find('ul')
      li = ul.find('li')
      expect(li).to.have.lengthOf 1
      expect(li).to.have.class 'no-terms'
      expect(li).to.have.text '[No terms]'
