#= require spec_helper
#= require views/terms/edit_terms_view

describe 'Coreon.Views.Terms.EditTermsView', ->

  view = null

  fakeApp = ->
    {}

  beforeEach ->
    view = new Coreon.Views.Terms.EditTermsView
      app: fakeApp()
      template: -> ''

  it 'inherits common terms view behaviour', ->
    expect(view).to.be.an.instanceOf Coreon.Views.Terms.AbstractTermsView

  it 'creates container', ->
    expect(view.$el).to.match '.terms.edit'

  describe '#initialize()', ->

    it 'assigns default template', ->
      view.initialize()
      template = view.template
      expect(template).to.equal Coreon.Templates['terms/edit_terms']

  describe '#createSubview()', ->

    constructor = null

    fakeModel = ->
      {}

    fakeView = ->
      {}

    beforeEach ->
      constructor = @stub Coreon.Views.Terms, 'EditTermView'

    it 'creates view for showing a term', ->
      model = fakeModel()
      termView = fakeView()
      constructor.withArgs(model: model).returns termView
      subview = view.createSubview model
      expect(subview).to.equal termView
