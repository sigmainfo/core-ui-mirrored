#= require spec_helper
#= require views/terms/term_view

describe 'Coreon.Views.Terms.TermView', ->

  view = null
  model = null
  properties = null
  propertiesView = null

  beforeEach ->
    sinon.stub Coreon.Views.Properties, 'PropertiesView', ->
      propertiesView = new Backbone.View
      propertiesView.render = sinon.spy()
      propertiesView

    model = new Backbone.Model
    model.info = -> {}
    model.hasProperties = -> no
    properties = new Backbone.Collection

    #TODO
    model.publicProperties = -> properties

    view = new Coreon.Views.Terms.TermView
      model: model

  afterEach ->
    Coreon.Views.Properties.PropertiesView.restore()

  it 'is a Backbone  view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'creates container', ->
    el = view.$el
    expect(el).to.match 'li.term'

  describe '#initialize()', ->

    it 'sets template from options', ->
      template = ->
      view.initialize template: template
      assigned = view.template
      expect(assigned).to.equal template

    it 'defaults template to be terms/term', ->
      view.initialize()
      assigned = view.template
      expect(assigned).to.equal Coreon.Templates['terms/term']

    it 'creates empty set for subviews', ->
      view.initialize()
      subviews = view.subviews
      expect(subviews).to.be.an.instanceOf Array
      expect(subviews).to.be.empty

  describe '#render()', ->

    template = null

    beforeEach ->
      template = sinon.stub()
      view.template = template

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    it 'is triggered by changes on term', ->
      render = sinon.spy()
      view.render = render
      view.initialize()
      model.trigger 'change'
      expect(view.render).to.have.been.calledOnce

    it 'clears subviews', ->
      subview = new Backbone.View
      remove = sinon.spy()
      subview.remove = remove
      view.subviews.push subview
      view.render()
      expect(remove).to.have.been.calledOnce
      subviews = view.subviews
      expect(subviews).to.be.empty

    context 'template', ->

      it 'updates content from template', ->
        view.$el.html '<h4 class="old">deprecated</h4>'
        template.returns '<h4>gun</h4>'
        view.render()
        updated = view.$('h4')
        expect(updated).to.exist
        expect(updated).to.have.text 'gun'
        old = view.$('h4.old')
        expect(old).to.not.exist

      it 'passes value to template', ->
        model.set 'value', 'handgun', silent: yes
        view.render()
        expect(template).to.have.been.calledOnce
        data = template.firstCall.args[0]
        expect(data).to.have.property 'value', 'handgun'

      it 'passes info to template', ->
        info = id: 'term123'
        model.info = -> info
        view.render()
        expect(template).to.have.been.calledOnce
        data = template.firstCall.args[0]
        expect(data).to.have.property 'info', info

    context 'properties', ->

      constructor = null

      beforeEach ->
        constructor = Coreon.Views.Properties.PropertiesView

      context 'with properties', ->

        beforeEach ->
          model.hasProperties = -> yes

        it 'creates subview', ->
          view.render()
          expect(constructor).to.have.been.calledOnce
          expect(constructor).to.have.been.calledWith
            model: properties

        it 'renders subview', ->
          view.render()
          render = propertiesView.render
          expect(render).to.have.been.calledOnce

        it 'appends subview', ->
          view.render()
          parent = view.el
          child = propertiesView.el
          expect($.contains parent, child).to.be.true

      context 'without properties', ->

        beforeEach ->
          model.hasProperties = -> no

        it 'does not create subview', ->
          view.render()
          expect(constructor).to.not.have.been.called
