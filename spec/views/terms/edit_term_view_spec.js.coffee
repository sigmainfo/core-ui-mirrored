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

  it 'includes confirmation dialog module', ->
    expect(view.confirm).to.equal Coreon.Modules.Confirmation.confirm

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

  describe '#removeTerm()', ->

    trigger = null

    beforeEach ->
      trigger = $ '<a class="remove-term" href="#">Remove term</a>'
      view.$el.append trigger

    context 'triggers', ->

      removeTerm = null

      beforeEach ->
        removeTerm = @stub view, 'removeTerm'
        view.delegateEvents()

      it 'is triggered by click on action', ->
        event = $.Event 'click'
        trigger.trigger event
        expect(removeTerm).to.have.been.calledOnce
        expect(removeTerm).to.have.been.calledWith event

    context 'confirmation', ->

      event = null
      confirm = null

      fakeEvent = ->
        target: trigger

      beforeEach ->
        event = fakeEvent()
        confirm = @stub view, 'confirm'

      opts = (confirm) ->
        confirm.firstCall.args[0]

      it 'pops up confirmation dialog', ->
        view.removeTerm event
        expect(confirm).to.have.been.calledOnce

      it 'passes trigger to dialog', ->
        event.target = trigger
        view.removeTerm event
        expect(opts confirm).to.have.property 'trigger', trigger

      it 'passes container to dialog', ->
        view.removeTerm event
        expect(opts confirm).to.have.property 'container', view.el

      it 'passes message to dialog', ->
        I18n.t.withArgs('term.confirm.remove_term').returns 'Are you sure?'
        view.removeTerm event
        expect(opts confirm).to.have.property 'message', 'Are you sure?'

      it 'destroys term when confirmed', ->
        view.removeTerm event
        expect(opts confirm).to.have.property 'action', 'destroyTerm'
