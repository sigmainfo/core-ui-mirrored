#= require spec_helper
#= require routers/repositories_router

describe "Coreon.Routers.RepositoriesRouter", ->
  
  beforeEach ->
    @view = new Backbone.View
    @view.repository = -> null
    @view.query = -> ""
    @view.switch = sinon.spy()
    @router = new Coreon.Routers.RepositoriesRouter @view
    Backbone.history.start silent: yes

  afterEach ->
    Backbone.history.stop()

  it "is a Backbone router", ->
    @router.should.be.an.instanceof Backbone.Router

  describe "root()", ->
  
    it "is routed", ->
      @router.root = sinon.spy()
      @router._bindRoutes()
      @router.navigate "other"
      @router.navigate "", trigger: yes
      @router.root.should.have.been.calledOnce

    it "redirects to current repository", ->
      @view.repository = -> id: "my-repo-123"
      @router.navigate = sinon.spy()
      @router.root()
      @router.navigate.should.have.been.calledOnce
      @router.navigate.should.have.been.calledWith "my-repo-123", trigger: yes, replace: yes

    it "kills session when no repository is available", ->
      @view.repository = -> null
      @router.navigate = sinon.spy()
      @router.root()
      @router.navigate.should.have.been.calledWith "logout"

  describe "show()", ->

    beforeEach ->
      sinon.stub Coreon.Views.Repositories, "RepositoryView", =>
        @screen = new Backbone.View arguments...

    afterEach ->
      Coreon.Views.Repositories.RepositoryView.restore()
  
    it "is routed", ->
      @router.show = sinon.spy()
      @router._bindRoutes()
      @router.navigate "50990fb960303934ea000041", trigger: yes
      @router.show.should.have.been.calledOnce
    
    it "switches repository", -> 
      @router.navigate = ->
      @view.repository = sinon.spy()
      @router.show "my-repo-abcdef"
      @view.repository.should.have.been.calledOnce
      @view.repository.should.have.been.calledWith "my-repo-abcdef"

    it "displays repository root", ->
      repository = new Backbone.Model "my-repo-abcdef"
      @view.repository = -> repository
      @router.view.switch = sinon.spy()
      @router.show "my-repo-abcdef"
      Coreon.Views.Repositories.RepositoryView.should.have.been.calledOnce
      Coreon.Views.Repositories.RepositoryView.should.have.been.calledWithNew
      Coreon.Views.Repositories.RepositoryView.should.have.been.calledWith model: repository
      @router.view.switch.should.have.been.calledWith @screen

    it "changes fragment when current repo is different from param", ->
      @router.navigate = sinon.spy()
      @view.repository = -> id: "some-other-id-567"
      @router.show "my-repo-abcdef"
      @router.navigate.should.have.been.calledWithExactly "some-other-id-567"

    it "redirects to root when repository is not available", ->
      @view.repository = -> null
      @router.navigate = sinon.spy()
      @router.show "ghost-repo-123"
      @router.navigate.should.have.been.calledOnce
      @router.navigate.should.have.been.calledWith "", trigger: yes, replace: yes

  describe "search()", ->

    beforeEach ->
      sinon.stub Coreon.Models, "Search", =>
        @search = new Backbone.Model
        @search.fetch = sinon.spy()
        @search

      sinon.stub Coreon.Models, "ConceptSearch", =>
        @conceptSearch = new Backbone.Model
        @conceptSearch.fetch = sinon.spy()
        @conceptSearch

      sinon.stub Coreon.Views.Search, "SearchResultsView", =>
        @screen = new Backbone.View
      
    afterEach ->
      Coreon.Models.Search.restore()
      Coreon.Models.ConceptSearch.restore()
      Coreon.Views.Search.SearchResultsView.restore()

    it "is routed", ->
      @router.search = sinon.spy()
      @router._bindRoutes()
      @router.navigate "51bedb0cd19879112b000004/search/movie", trigger: yes
      @router.search.should.have.been.calledOnce
      @router.search.should.have.been.calledWith "51bedb0cd19879112b000004", "movie"

    it "switches repository", ->
      @view.repository = sinon.spy()
      @router.search "my-repo-abcdef", "poet"
      @view.repository.should.have.been.calledWith "my-repo-abcdef"

    it "triggers term search", ->
      @router.search "my-repo-abcdef", "poet"
      Coreon.Models.Search.should.have.been.calledOnce
      Coreon.Models.Search.should.have.been.calledWithNew
      Coreon.Models.Search.should.have.been.calledWith
        path: "terms/search"
        query: "poet"
      @search.fetch.should.have.been.calledOnce

    it "triggers concept search", ->
      @router.search "my-repo-abcdef", "poet"
      Coreon.Models.ConceptSearch.should.have.been.calledOnce
      Coreon.Models.ConceptSearch.should.have.been.calledWithNew
      Coreon.Models.ConceptSearch.should.have.been.calledWith
        path: "concepts/search"
        query: "poet"
      @conceptSearch.fetch.should.have.been.calledOnce

    it "decodes query string", ->
      @router.search "my-repo-abcdef", "Whahappan%3F"
      Coreon.Models.Search.firstCall.args[0].should.have.property "query", "Whahappan?"
      Coreon.Models.ConceptSearch.firstCall.args[0].should.have.property "query", "Whahappan?"

    it "displays search results", ->
      @router.search "my-repo-abcdef", "Whahappan%3F"
      Coreon.Views.Search.SearchResultsView.should.have.been.calledOnce
      Coreon.Views.Search.SearchResultsView.should.have.been.calledWithNew
      Coreon.Views.Search.SearchResultsView.should.have.been.calledWith
        models:
          terms: @search
          concepts: @conceptSearch
      @view.switch.should.have.been.calledWith @screen

    it "displays query string within search input", ->
      @view.query = sinon.spy()
      @router.search "my-repo-abcdef", "poet"
      @view.query.should.have.been.calledOnce
      @view.query.should.have.been.calledWith "poet"
      
      
      
