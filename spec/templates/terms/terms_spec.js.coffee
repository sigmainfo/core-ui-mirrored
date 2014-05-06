#= require spec_helper
#= require templates/terms/terms

describe 'Coreon.Templates[terms/terms]', ->

  template = Coreon.Templates['terms/terms']
  data = null

  render = ->
    $('<div>').html(template data)

  beforeEach ->
    data =
      languages: []
      hasProperties: no

  context 'languages', ->

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

  context 'properties', ->

    it 'renders toggle when applicable', ->
      data.hasProperties = yes
      I18n.t
        .withArgs('terms.properties.toggle-all')
        .returns 'Toggle all properties'
      el = render()
      toggle = el.find('.properties-toggle')
      expect(toggle).to.exist
      expect(toggle).to.have.attr 'title', 'Toggle all properties'
      text = toggle.text().trim()
      expect(text).to.equal 'Toggle all properties'

    it 'does not render toggle when not applicable', ->
      data.hasProperties = no
      el = render()
      toggle = el.find('.properties-toggle')
      expect(toggle).to.not.exist
