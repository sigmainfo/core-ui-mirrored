#= require spec_helper
#= require views/panels/terms/edit_term_view

describe 'Coreon.Views.Panels.Terms.EditTermView', ->

  view = null
  model = null

  beforeEach ->
    model = new Backbone.Model
    model.info = ->
    view = new Coreon.Views.Panels.Terms.EditTermView model: model

  it 'is a backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'has a container', ->
    el = view.$el
    expect(el).to.match 'div'

  describe '#render()', ->

    it 'renders a form', ->
      sinon.spy Coreon.Helpers, 'form_for'
      el = view.render().$else
      expect(Coreon.Helpers.form_for).to.have.been.calledOnce

    it 'renders a hidden input for the term id', ->
      model.id = '1'
      view.render()
      input = view.$('input[type=hidden][name=id]')
      expect(input).to.have.attr 'value', '1'

    it 'renders an input for the term value', ->
      model.set 'value', 'car'
      view.render()
      input = view.$('input[type=text][name="term[value]"]')
      expect(input).to.have.attr 'value', 'car'

    it 'renders an input for the lang value', ->
      model.set 'lang', 'en'
      view.render()
      input = view.$('input[type=text][name="term[lang]"]')
      expect(input).to.have.attr 'value', 'en'


