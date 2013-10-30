#= require spec_helper
#= require templates/repositories/repository_select
#= require views/repositories/repository_select_view

describe "Coreon.Views.Repositories.RepositorySelectView", ->
  
  beforeEach ->
    @repositories = [
      {id:0, name:"c0ffee"},
      {id:1, name:"f00bee"}
    ]
    @model = new Backbone.Model
    @currentRepository = new Backbone.Model
    @model.currentRepository = => @currentRepository
    @model.set repositories: @repositories, silent: true
    @view = new Coreon.Views.Repositories.RepositorySelectView
      model: @model
    sinon.stub I18n, "t"

  afterEach ->
    I18n.t.restore()

  it "is a Backbone view", ->
    expect( @view ).to.be.an.instanceof Backbone.View

  describe "prompt()", ->
    
    it "includes method from module", ->
      expect( Coreon.Modules.Prompt ).to.exist
      expect( @view.prompt ).to.equal Coreon.Modules.Prompt.prompt

  describe "render()", ->
    
    it "is chainable", ->
      expect( @view.render() ).to.equal @view

    it "is triggered by model changes", ->
      @view.render = sinon.spy()
      @view.initialize()
      @model.trigger "change:repositories"
      expect( @view.render ).to.have.been.calledOnce

    it "renders current repository", ->
      sinon.stub @model, 'currentRepository', =>
        @model.get('repositories')[0]
      
      @model.set "repositories", [
        { id: 0, name: "My Repository" }
      ], silent: true
      @view.render()
      
      expect( @view.$el ).to.have ".coreon-select"
      expect( @view.$(".coreon-select") ).to.contain "My Repository"
      
      @model.currentRepository.restore

    context "multiple repositories", ->

      it "does not mark single", ->
        @view.render()
        expect( @view.$(".coreon-select") ).to.not.have.class "single"

    context "single repository", ->
      
      beforeEach ->
        @model.set "repositories", [ id: 0, name: "c0ffee" ], silent: true

      it "renders selector", ->
        @view.render()
        expect( @view.$el ).to.not.have "a.select"

      it "marks single", ->
        @view.render()
        expect( @view.$(".coreon-select") ).to.have.class "single"

  #
  # Not needed anymore, but a test for CoreonSelectPopup would be nice 
  # TODO: Test for CoreonSelectPopup
  #
  # describe "select()", ->
  # 
  #   beforeEach ->
  #     $("#konacha").append $('<div id="coreon-modal">')
  #     $("#konacha").append @view.render().$el
  #     @event = $.Event "click"
  # 
  #   it "creates dropdown view", ->
  #     Coreon.Views.Repositories.RepositorySelectDropdownView.reset()
  #     @view.prompt = sinon.spy()
  #     @view.select @event
  #     expect( Coreon.Views.Repositories.RepositorySelectDropdownView ).to.have.been.calledOnce
  #     expect( Coreon.Views.Repositories.RepositorySelectDropdownView ).to.have.been.calledWithNew
  #     expect( Coreon.Views.Repositories.RepositorySelectDropdownView ).to.have.been.calledWith model: @model
  #     expect( @view.prompt ).to.have.been.calledOnce
  #     expect( @view.prompt ).to.have.been.calledWith @dropdown
  # 
  #   it "positions dropdown relative to current", ->
  #     @view.$("h4").css
  #       position: "absolute"
  #       left: 44
  #       top: 8
  #       height: 16
  #     @view.select @event
  #     pos = @dropdown.$el.position()
  #     expect( pos.left ).to.equal 44
  #     expect( pos.top ).to.equal 28
