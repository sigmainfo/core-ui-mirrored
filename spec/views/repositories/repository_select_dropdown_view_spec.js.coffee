#= require spec_helper
#= require jquery.ui.position
#= require templates/repositories/repository_select_dropdown
#= require views/repositories/repository_select_dropdown_view

describe "Coreon.Views.Repositories.RepositorySelectDropdownView", ->

  beforeEach ->
    sinon.stub I18n, "t"
    @selector = $("<h4 class=\"current\">").appendTo "#konacha"
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
    @view = new Coreon.Views.Repositories.RepositorySelectDropdownView
      model: @model
      selector: @selector

  afterEach ->
    I18n.t.restore()

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  describe "render()", ->

    beforeEach ->
      @selector.css
        position: "absolute"
        top: 23
        left: 42
      @selector.appendTo "#konacha"
      @view.$el.appendTo "#konacha"

    it "is chainable", ->
      @view.render().should.equal @view

    it "renders repositories", ->
      @view.render()
      @view.$("li").length.should.equal @repositories.length
      @view.$("li").eq(0).text().should.contain @repositories[0].name
      @view.$("li").eq(1).text().should.contain @repositories[1].name

    it "sets positions relative to given selector element", ->
      @view.render()
      @view.$("ul.options").css("top").should.equal "23px"
      @view.$("ul.options").css("left").should.equal "42px"

  describe "close()", ->

    it "can prompt", ->
      should.exist Coreon.Modules.Prompt
      @view.prompt.should.equal Coreon.Modules.Prompt.prompt
    
    it "should remove menu", ->
      @view.prompt = sinon.spy()
      @view.close()
      @view.prompt.should.have.been.calledOnce
      @view.prompt.should.have.been.calledWith null

  describe "fixate()", ->
    beforeEach ->
      $('#konacha').append @view.$el
      @view.render()
      @width = @view.fixate()

    afterEach ->
      @model.set
        repositories: [
          {id:0, name:"c0ffee"},
          {id:1, name:"f00bee"}
        ]

    it "should grow", ->
      @model.set
        repositories: [
          {id:0, name:"a bunch of c0ffee beans"},
          {id:1, name:"f00bee"}
        ]
      @view.render()
      @view.fixate().should.be.above @width

    it "should shrink", ->
      @model.set
        repositories: [
          {id:0, name:"no"},
          {id:1, name:"yes"}
        ]
      @view.render()
      @view.fixate().should.be.below @width

    it "should set the selectors width", ->
      w = @view.fixate()
      @selector.width().should.equal w-27

