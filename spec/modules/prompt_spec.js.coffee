#= require spec_helper
#= require modules/helpers
#= require modules/prompt

describe "Coreon.Modules.Prompt", ->

  before ->
    class Coreon.Views.ViewWithPrompt extends Backbone.View
      Coreon.Modules.include @, Coreon.Modules.Prompt

  after ->
    delete Coreon.Views.ViewWithPrompt

  beforeEach ->
    @view = new Coreon.Views.ViewWithPrompt

  describe "prompt()", ->

    beforeEach ->
      @modal = $('<div id="coreon-modal">"')
      $("#konacha").append @modal

    it "clears modal layer", ->
      @modal.html "<p>fooo</p>"
      @view.prompt()
      @modal.should.be.empty

    it "renders passed view on modal layer", ->
      widget = new Backbone.View
      widget.render = @stub().returns widget
      @view.prompt widget
      widget.render.should.have.been.calledOnce
      $.contains(@modal[0], widget.el).should.be.true

    it "removes currently displayed view", ->
      current = new Backbone.View
      current.remove = @spy()
      next = new Backbone.View
      @view.prompt current
      @view.prompt next
      current.remove.should.have.been.calledOnce

