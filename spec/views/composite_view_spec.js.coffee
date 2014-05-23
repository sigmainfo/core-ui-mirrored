#= require spec_helper
#= require views/composite_view

describe "Coreon.Views.CompositeView", ->

  collection = null
  view = null

  stubModel = ->
    {}

  stubCollection = ->
    models: []

  stubSubview = ->
    render: -> @
    remove: ->
    el: $('<div>')

  beforeEach ->
    collection = stubCollection()
    view = new Coreon.Views.CompositeView model: collection

  describe '#initialize()', ->

    it 'creates empty list for subviews', ->
      expect(view).to.have.property('subviews').that.is.an.emptyArray

  describe '#render()', ->

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    it 'renders subviews', ->
      renderSubviews = @spy view, 'renderSubviews'
      view.render()
      expect(renderSubviews).to.have.been.calledOnce

  describe '#renderSubviews()', ->

    it 'removes subviews', ->
      removeSubviews = @spy view, 'removeSubviews'
      view.renderSubviews()
      expect(removeSubviews).to.have.been.calledOnce

    it 'creates subviews for models', ->
      createSubviews = @spy view, 'createSubviews'
      models = [ stubModel() ]
      view.renderSubviews models
      expect(createSubviews).to.have.been.calledOnce
      expect(createSubviews).to.have.been.calledWith models

    it 'creates subviews from collection by default', ->
      createSubviews = @spy view, 'createSubviews'
      models = [ stubModel() ]
      collection.models = models
      view.renderSubviews()
      expect(createSubviews).to.have.been.calledWith models

    it 'renders created subviews', ->
      subview = stubSubview()
      render = @spy subview, 'render'
      createSubviews = @stub(view, 'createSubviews').returns [subview]
      view.renderSubviews [ stubModel() ]
      expect(render).to.have.been.calledOnce

    it 'inserts rendered subviews', ->
      subviews = [ stubSubview() ]
      createSubviews = @stub(view, 'createSubviews').returns subviews
      insertSubviews = @stub view, 'insertSubviews'
      view.renderSubviews [ stubModel() ]
      expect(insertSubviews).to.have.been.calledOnce
      expect(insertSubviews).to.have.been.calledWith subviews

    it 'returns rendered subviews', ->
      subviews = [ stubSubview() ]
      createSubviews = @stub(view, 'createSubviews').returns subviews
      result = view.renderSubviews [ stubModel() ]
      expect(result).to.equal subviews

  describe '#removeSubviews()', ->

    it 'triggers removal of subviews', ->
      subview = stubSubview()
      remove = @spy subview, 'remove'
      view.removeSubviews [subview]
      expect(remove).to.have.been.calledOnce

    it 'defaults to remove all subviews', ->
      subview = stubSubview()
      remove = @spy subview, 'remove'
      view.subviews = [subview]
      view.removeSubviews()
      expect(remove).to.have.been.calledOnce

    it 'removes references to subviews', ->
      subview1 = stubSubview()
      subview2 = stubSubview()
      view.subviews = [subview1, subview2]
      view.removeSubviews [subview1]
      expect(view.subviews).to.eql [subview2]

  describe '#createSubviews()', ->

    it 'creates subviews for models', ->
      model = stubModel()
      factory = @spy view, 'createSubview'
      view.createSubviews [model]
      expect(factory).to.have.been.calledOnce
      expect(factory).to.have.been.calledWith model

    it 'defaults to models from collection', ->
      model = stubModel()
      factory = @spy view, 'createSubview'
      collection.models = [model]
      view.createSubviews()
      expect(factory).to.have.been.calledOnce
      expect(factory).to.have.been.calledWith model

    it 'adds references to subviews', ->
      subview1 = stubSubview()
      subview2 = stubSubview()
      view.createSubview = -> subview2
      view.subviews = [subview1]
      view.createSubviews [ stubModel() ]
      expect(view.subviews).to.eql [subview1, subview2]

    it 'returns newly created subviews', ->
      subview1 = stubSubview()
      subview2 = stubSubview()
      view.createSubview = -> subview2
      view.subviews = [subview1]
      result = view.createSubviews [ stubModel() ]
      expect(result).to.eql [subview2]

  describe 'createSubview()', ->

    model = null

    beforeEach ->
      model = stubModel()

    it 'creates plain Backbone view', ->
      result = view.createSubview model
      expect(result).to.be.an.instanceOf Backbone.View

    it 'assigns model instance', ->
      result = view.createSubview model
      expect(result).to.have.property 'model', model

  describe '#insertSubviews()', ->

    subview = null

    beforeEach ->
      subview = stubSubview()

    it 'inserts each subview', ->
      insert = @spy view, 'insertSubview'
      view.insertSubviews [subview]
      expect(insert).to.have.been.calledOnce
      expect(insert).to.have.been.calledWith subview

    it 'defaults to all subviews', ->
      insert = @spy view, 'insertSubview'
      view.subviews = [subview]
      view.insertSubviews()
      expect(insert).to.have.been.calledOnce
      expect(insert).to.have.been.calledWith subview

  describe '#insertSubview()', ->

    it 'appends subview to container', ->
      subview = stubSubview()
      view.insertSubview subview
      expect(subview.el).to.be.childOf view.el
