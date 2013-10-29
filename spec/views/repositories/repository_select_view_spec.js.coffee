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
    @view.should.be.an.instanceof Backbone.View

  describe "prompt()", ->
  
    it "includes method from module", ->
      should.exist Coreon.Modules.Prompt
      @view.prompt.should.equal Coreon.Modules.Prompt.prompt

  describe "render()", ->

    it "is chainable", ->
      @view.render().should.equal @view

    it "is triggered by model changes", ->
      @view.render = sinon.spy()
      @view.initialize()
      @model.trigger "change:repositories"
      @view.render.should.have.been.calledOnce

    it "renders current repository", ->
      sinon.stub @model, 'currentRepository', =>
        @model.get('repositories')[0]
      
      @model.set "repositories", [
        { id: 0, name: "My Repository" }
      ], silent: true
      @view.render()
      @view.$el.should.have ".coreon-select"
      @view.$(".coreon-select").should.contain "My Repository"
      
      @model.currentRepository.restore

    context "multiple repositories", ->

      it "does not mark single", ->
        @view.render()
        @view.$(".coreon-select").should.not.have.class "single"

    context "single repository", ->
      
      beforeEach ->
        @model.set "repositories", [ id: 0, name: "c0ffee" ], silent: true

      it "renders selector", ->
        @view.render()
        @view.$el.should.not.have "a.select"

      it "marks single", ->
        @view.render()
        @view.$(".coreon-select").should.have.class "single"

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
  #     Coreon.Views.Repositories.RepositorySelectDropdownView.should.have.been.calledOnce
  #     Coreon.Views.Repositories.RepositorySelectDropdownView.should.have.been.calledWithNew
  #     Coreon.Views.Repositories.RepositorySelectDropdownView.should.have.been.calledWith model: @model
  #     @view.prompt.should.have.been.calledOnce
  #     @view.prompt.should.have.been.calledWith @dropdown
  # 
  #   it "positions dropdown relative to current", ->
  #     @view.$("h4").css
  #       position: "absolute"
  #       left: 44
  #       top: 8
  #       height: 16
  #     @view.select @event
  #     pos = @dropdown.$el.position()
  #     pos.left.should.equal 44
  #     pos.top.should.equal 28
