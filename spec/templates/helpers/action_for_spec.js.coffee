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

    it 'renders label as text', ->
      el = $ template label: 'Toggle me'
      expect(el).to.have.text 'Toggle me'

    it 'renders hint as tooltip', ->
      el = $ template hint: 'Click here to toggle'
      expect(el).to.have.attr 'title', 'Click here to toggle'

    it 'adds class name to link', ->
      el = $ template name: 'toggle-me'
      expect(el).to.have.class 'toggle-me'
