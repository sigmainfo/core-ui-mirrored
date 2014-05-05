#= require spec_helper
#= require templates/helpers/action_for

describe 'Coreon.Templates[helpers/action_for]', ->

  template = Coreon.Templates['helpers/action_for']

  context 'head', ->

    it 'renders link tag', ->
      el = $ template()
      expect(el).to.be 'a'

    it 'renders null link', ->
      el = $ template()
      expect(el).to.have.attr 'href', 'javascript:void(0)'

    it 'renders title as text and tooltip', ->
      el = $ template title: 'Toggle me'
      expect(el).to.have.text 'Toggle me'
      expect(el).to.have.attr 'title', 'Toggle me'

    it 'adds class name to link', ->
      el = $ template name: 'toggle-me'
      expect(el).to.have.class 'toggle-me'
