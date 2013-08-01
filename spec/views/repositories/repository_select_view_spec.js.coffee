#= require spec_helper
#= require templates/repositories/repository_select_dropdown
#= require views/application_view
#= require views/repositories/repository_select_dropdown_view
#= require views/repositories/repository_select_view

describe "Coreon.Views.Repositories.RepositorySelectView", ->

  beforeEach ->
    @repositories = [
      {id:0, name:"c0ffee"},
      {id:1, name:"f00bee"}
    ]
    @model = new Backbone.Model
    @model.currentRepository = =>
      new Backbone.Model
        id:0
        name:"c0ffee"
    @model.set repositories: @repositories
    @app = new Backbone.View
      model: @model
    @app.prompt = sinon.spy()
    @view = new Coreon.Views.Repositories.RepositorySelectView
      model: @model
      app: @app
    sinon.stub I18n, "t"

  afterEach ->
    I18n.t.restore()

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  describe "render()", ->
    beforeEach ->
      sinon.stub @view, "select"

    afterEach ->
      @view.select.restore()

    it "is chainable", ->
      @view.render().should.equal @view

    it "calls select", ->
      @view.render()
      @view.select.should.have.been.calledOnce

  describe "select()", ->

    beforeEach ->
      sinon.stub Coreon.Views.Repositories, "RepositorySelectDropdownView", =>
        @dropdown = new Backbone.View
        @dropdown.fixate = ->
        @dropdown

    afterEach ->
      Coreon.Views.Repositories.RepositorySelectDropdownView.restore()

    it "creates dropdown view", ->
      selector = $("<h4 class=\"current\">").appendTo @view.$el
      @view.select()
      Coreon.Views.Repositories.RepositorySelectDropdownView.should.have.been.calledOnce
      Coreon.Views.Repositories.RepositorySelectDropdownView.should.have.been.calledWithNew
      options = Coreon.Views.Repositories.RepositorySelectDropdownView.firstCall.args[0]
      options.model.should.equal @model
      options.app.should.equal @app
      options.selector.get(0).should.equal selector.get(0)

    it "passes dropdown to prompt method", ->
      @view.select()
      @app.prompt.should.have.been.calledOnce
      @app.prompt.should.have.been.calledWith @dropdown
