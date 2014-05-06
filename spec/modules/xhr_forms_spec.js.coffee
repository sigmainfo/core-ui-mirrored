#= require spec_helper
#= require modules/helpers
#= require modules/xhr_forms

describe "Coreon.Modules.XhrForms", ->

  before ->
    class Coreon.Views.ViewWithXhrForms extends Backbone.View
      Coreon.Modules.include @, Coreon.Modules.XhrForms

      initialize: ->
        @xhrFormsOn()

  after ->
    delete Coreon.Views.ViewWithXhrForms

  beforeEach ->
    @view = new Coreon.Views.ViewWithXhrForms

  context "submit", ->

    describe "disable", ->

      beforeEach ->
        @view.$el.html '''
          <form data-xhr-form="disable" action="javascript:void(0)">
            <input type="text">
            <textarea></textarea>
            <button type="submit">Submit</button>
          </form>
        '''
        @form = @view.$("form")
        @event = $.Event "submit"
        @event.target = @form[0]

      it "disables all controls on submit", ->
        @form.trigger @event
        @view.$("input" ).should.be.disabled
        @view.$("textarea" ).should.be.disabled
        @view.$("button" ).should.be.disabled

      it "marks all links inside the form as being disabled", ->
        @view.$el.append '<a class="outside">click me</a>'
        @view.$("form").append '<a class="inside">click me</a>'
        @form.trigger @event
        @view.$(".inside").should.have.class "disabled"
        @view.$(".outside").should.not.have.class "disabled"

      it "deactivates all links", ->
        spy = @spy()
        @link = $ '<a href="#">click me</a>'
        @view.$("form").append @link
        @view.$el.on "click", "a", spy
        @form.trigger @event
        @link.click()
        spy.should.not.have.been.called

    describe "other", ->

      beforeEach ->
        @view.$el.html '''
          <form action="javascript:void(0)">
            <input type="text">
            <textarea></textarea>
            <button type="submit">Submit</button>
          </form>
        '''
        @form = @view.$("form")
        @event = $.Event "submit"
        @event.target = @form[0]

      it "disables all controls on submit", ->
        @form.trigger @event
        @view.$("input" ).should.not.be.disabled
        @view.$("textarea" ).should.not.be.disabled
        @view.$("button" ).should.not.be.disabled

      it "marks all links inside the form as being disabled", ->
        @view.$("form").append '<a href="#">click me</a>'
        @form.trigger @event
        @view.$("a").should.not.have.class "disabled"

      it "deactivates all links", ->
        spy = @spy()
        @link = $ '<a href="#">click me</a>'
        @view.$("form").append @link
        @view.$el.on "click", "a", spy
        @form.trigger @event
        @link.click()
        spy.should.have.been.calledOnce
