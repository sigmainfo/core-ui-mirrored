#= require spec_helper
#= require views/concepts/concept_label_list_view

describe 'Coreon.Views.Concept.ConceptLabelListView', ->

  view = null

  beforeEach ->
    @stub Coreon.Views.Concepts, 'ConceptLabelView'
    Coreon.Views.Concepts.ConceptLabelView.returns new Backbone.View

    view = new Coreon.Views.Concepts.ConceptLabelListView
      models: []

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  describe '#initialize()', ->

    it 'creates collection from models', ->
      concept = new Backbone.Model
      models = [concept]
      view.initialize models: models
      model = view.model
      expect(model).to.be.an.instanceOf Backbone.Collection
      expect(model).to.have.lengthOf 1
      first = model.first()
      expect(first).to.equal concept

  describe '#render()', ->

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    it 'is triggered on label changes', ->
      render = @spy()
      view.render = render
      view.initialize()
      view.model.trigger 'change:label'
      expect(render).to.have.been.calledOnce

    it 'clears container', ->
      el = view.$el
      el.html '<p>I am dead – am I?</p>'
      view.model.reset [], silent: yes
      view.render()
      expect(el).to.be.empty

    it 'removes old labels', ->
      label = new Backbone.View
      constructor = Coreon.Views.Concepts.ConceptLabelView
      constructor.returns label
      remove = @spy()
      label.remove = remove
      view.model.reset [ new Backbone.Model ], silent: yes
      view.render()
      view.model.reset [], silent: yes
      view.render()
      expect(remove).to.have.been.calledOnce

    it 'renders a label for each concept', ->
      concept = new Backbone.Model
      view.model.reset [concept], silent: yes
      label = new Backbone.View
      render = @spy()
      label.render = render
      constructor = Coreon.Views.Concepts.ConceptLabelView
      constructor.withArgs(model: concept).returns label
      view.render()
      expect(render).to.have.been.calledOnce
      container = view.el
      el = label.el
      expect($.contains container, el).to.be.true

    it 'sorts labels alphabetically', ->
      concepts = []
      subviews = []
      constructor = Coreon.Views.Concepts.ConceptLabelView
      ['b', 'a', 'c'].forEach (label) ->
        concept = new Backbone.Model label: label
        concepts.push concept
        subview = new Backbone.View model: concept
        subviews.push subview
        constructor.withArgs(model: concept).returns subview
      view.model.reset concepts, silent: yes
      view.render()
      children = view.$el.children()
      expect(children[0]).to.equal subviews[1].el
      expect(children[1]).to.equal subviews[0].el
      expect(children[2]).to.equal subviews[2].el
