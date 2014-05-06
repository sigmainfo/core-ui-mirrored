#= require spec_helper
#= require modules/helpers
#= require modules/nested_fields_for

describe "Coreon.Modules.NestedFieldsFor", ->

  before ->
    @original_templates = Coreon.Templates
    Coreon.Templates = {}

    class Coreon.Views.MyView extends Backbone.View
      Coreon.Modules.extend @, Coreon.Modules.NestedFieldsFor

  after ->
    Coreon.Templates = @original_templates
    delete Coreon.Views.MyView

  beforeEach ->
    @view = new Coreon.Views.MyView

  context "with defaults", ->

    beforeEach ->
      Coreon.Templates["terms/new_term"] = @stub()
      Coreon.Views.MyView.nestedFieldsFor "terms"

    describe "removeTerm()", ->

      beforeEach ->
        @view.$el.append '''
          <fieldset id="existing-term" class="term">
            <a class="remove-term">Remove term</a>
          </fieldset>
          <fieldset id="new-term" class="term not-persisted">
            <a class="remove-term">Remove term</a>
            <input type="hidden" name="concept[terms][42][id]">
          </fieldset>
          '''
        @event = $.Event "click"

      it "removes fields of non-existing term", ->
        @event.target = @view.$("#new-term .remove-term")[0]
        @view.removeTerm @event
        @view.$el.should.not.have "#new-term"
        @view.$el.should.have "#existing-term"

      it "marks fields of existing term as deleted", ->
        @event.target = @view.$("#existing-term .remove-term")[0]
        @view.removeTerm @event
        @view.$el.should.have "#existing-term"
        @view.$el.should.have "#new-term"
        @view.$('#existing-term').should.have.class "delete"

    describe "addTerm()", ->

      beforeEach ->
        Coreon.Templates["terms/new_term"].reset()
        @view.$el.append '''
          <div class="terms">
            <h3>TERMS</h3>
            <div class="add">
              <div class="edit">
                <a class="add-term">Add term</a>
              </div>
            </div>
          </div>
          '''
        @event = $.Event "click"
        @trigger = @view.$(".add-term")
        @event.target = @trigger[0]

      it "inserts template before trigger", ->
        Coreon.Templates["terms/new_term"].returns '<fieldset class="term"></fieldset>'
        @view.addTerm @event
        @view.$el.should.have ".terms > .term"
        @view.$(".term").next().should.match ".add"

      it "passes data attributes to template", ->
        @trigger.attr "data-scope", "concept[terms][]"
        @view.addTerm @event
        Coreon.Templates["terms/new_term"].firstCall.args[0].should.have.property "scope", "concept[terms][]"

      it "passes increasing index to template", ->
        @view.addTerm @event
        @view.addTerm @event
        Coreon.Templates["terms/new_term"].firstCall.args[0].should.have.property "index", 0
        Coreon.Templates["terms/new_term"].secondCall.args[0].should.have.property "index", 1

      it "starts on given index", ->
        @trigger.attr "data-index", 5
        @view.addTerm @event
        @view.addTerm @event
        Coreon.Templates["terms/new_term"].firstCall.args[0].should.have.property "index", 5
        Coreon.Templates["terms/new_term"].secondCall.args[0].should.have.property "index", 6

      it "classifies template as being not yet persisted", ->
        Coreon.Templates["terms/new_term"].returns '<fieldset class="term"></fieldset>'
        @view.addTerm @event
        @view.$(".term").should.match ".not-persisted"

  context "with custom options", ->

    before ->
      Coreon.Views.MyView.nestedFieldsFor "properties",
        className: "term-property"
        template: -> '<fieldset class="term-property"></fieldset>'
        as: "TermProperty"

    describe "removeTermProperty()", ->

      beforeEach ->
        @view.$el.append '''
          <fieldset class="term-property not-persisted">
            <a class="remove-property">Remove property</a>
          </fieldset>
          '''
        @event = $.Event "click"

      it "removes fields", ->
        @event.target = @view.$(".remove-property")[0]
        @view.removeTermProperty @event
        @view.$el.should.not.have ".term-property"

    describe "addTermProperty()", ->

      beforeEach ->
        @view.$el.append '''
          <div class="properties">
            <div class="edit">
              <a class="add-term-property">Add term</a>
            </div>
          </div>
          '''
        @event = $.Event "click"
        @trigger = @view.$(".add-term-property")
        @event.target = @trigger[0]

      it "inserts template", ->
        @view.addTermProperty @event
        @view.$el.should.have ".term-property"
