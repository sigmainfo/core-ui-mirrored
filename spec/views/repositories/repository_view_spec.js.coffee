#= require spec_helper
#= require views/repositories/repository_view

describe "Coreon.Views.Repositories.RepositoryView", ->

  beforeEach ->
    Coreon.Helpers.repositoryPath = -> "/coffee23/concepts/new"
    @view = new Coreon.Views.Repositories.RepositoryView
    sinon.stub I18n, "t"

  afterEach ->
    I18n.t.restore()

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  describe "render()", ->

    beforeEach ->
      Coreon.Helpers.can = -> true

    afterEach ->
      Coreon.application = null

    it "is chainable", ->
      @view.render().should.equal @view

    context "with maintainer privileges", ->
    
      beforeEach ->
        Coreon.Helpers.can = -> true
  
      it "renders link to new concept form", ->
        I18n.t.withArgs("concept.new").returns "New concept"
        @view.render()
        @view.$el.should.have 'a[href="/coffee23/concepts/new"]'
        @view.$('a[href="/coffee23/concepts/new"]').should.have.text "New concept"

    context "without maintainer privileges", ->
    
      beforeEach ->
        Coreon.Helpers.can = -> false
  
      it "renders link to new concept form", ->
        @view.render()
        @view.$el.should.not.have 'a[href="/concepts/new"]'
