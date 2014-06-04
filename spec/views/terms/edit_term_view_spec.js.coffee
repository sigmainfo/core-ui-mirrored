#= require spec_helper
#= require views/terms/edit_term_view

describe 'Coreon.Views.Terms.EditTermView', ->

  term = null
  view = null
  template = null

  fakeTerm = (attrs) -> new Backbone.Model attrs

  beforeEach ->
    term = fakeTerm()
    view = new Coreon.Views.Terms.EditTermView
      model: term
      template: -> ''

  it 'derives common behavior from term view', ->
    expect(view).to.be.an.instanceOf Coreon.Views.Terms.TermView

  it 'classifies container', ->
    el = view.$el
    expect(el).to.have.class 'term'
    expect(el).to.have.class 'edit'
    expect(el).to.not.have.class 'show'

  describe '#initialize()', ->

    it 'assigns default template', ->
      view.initialize()
      assigned = view.template
      expect(assigned).to.equal Coreon.Templates['terms/edit_term']
