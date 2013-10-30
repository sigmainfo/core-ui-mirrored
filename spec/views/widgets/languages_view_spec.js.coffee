#= require spec_helper
#= require views/widgets/languages_view

describe "Coreon.Views.LanguagesView", ->

  beforeEach ->
    Coreon.application = repository: ->
      id: "my-repo"
      get: -> "MY REPO"
    
    sinon.stub I18n, "t"

    model = new Backbone.Model
    @view = new Coreon.Views.Widgets.LanguagesView
      model: model

  afterEach ->
    I18n.t.restore()
    delete Coreon.application

  it "is a Backbone view", ->
    expect( @view ).to.be.an.instanceOf Backbone.View

  it "creates container", ->
    expect( @view.$el ).to.have.id "coreon-languages"

  describe "render()", ->

    it "can be chained", ->
      expect( @view.render() ).to.equal @view

    it "renders form", ->
      @view.render()
      expect( @view.$el ).to.have "form.languages"