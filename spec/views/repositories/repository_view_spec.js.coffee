#= require spec_helper
#= require views/repositories/repository_view

describe "Coreon.Views.Repositories.RepositoryView", ->

  beforeEach ->
    @view = new Coreon.Views.Repositories.RepositoryView
    sinon.stub I18n, "t"

  afterEach ->
    I18n.t.restore()

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View 

  describe "render()", ->

    beforeEach ->
      Coreon.application = session: ability: can: sinon.stub()

    afterEach ->
      Coreon.application = null    

    it "is chainable", ->
      @view.render().should.equal @view

    context "with maintainer privileges", ->
    
      beforeEach ->
        Coreon.application.session.ability.can.withArgs("create", Coreon.Models.Concept).returns true
  
      it "renders link to new concept form", ->
        I18n.t.withArgs("concept.new").returns "New concept"
        @view.render()
        @view.$el.should.have 'a[href="/concepts/new"]'
        @view.$('a[href="/concepts/new"]').should.have.text "New concept"

    context "without maintainer privileges", ->
    
      beforeEach ->
        Coreon.application.session.ability.can.withArgs("create", Coreon.Models.Concept).returns false
  
      it "renders link to new concept form", ->
        @view.render()
        @view.$el.should.not.have 'a[href="/concepts/new"]'
