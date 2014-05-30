#= require spec_helper
#= require views/terms/terms_view

describe 'Coreon.Views.Terms.TermsView', ->

  view = null

  fakeApp = ->
    {}

  beforeEach ->
    view = new Coreon.Views.Terms.TermsView
      app: fakeApp()
      template: -> ''

  it 'inherits common terms view behaviour', ->
    expect(view).to.be.an.instanceOf Coreon.Views.Terms.AbstractTermsView

  it 'creates container', ->
    expect(view.$el).to.match '.terms.show'

  describe '#initialize()', ->

    app = null

    beforeEach ->
      app = fakeApp()

    it 'assigns default template', ->
      view.initialize app: app
      template = view.template
      expect(template).to.equal Coreon.Templates['terms/terms']

  describe '#createSubview()', ->

    constructor = null

    fakeModel = ->
      {}

    fakeView = ->
      {}

    beforeEach ->
      constructor = @stub Coreon.Views.Terms, 'TermView'

    it 'creates view for showing a term', ->
      model = fakeModel()
      termView = fakeView()
      constructor.withArgs(model: model).returns termView
      subview = view.createSubview model
      expect(subview).to.equal termView
