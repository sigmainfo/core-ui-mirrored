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
    
    before ->
      Coreon.Templates["terms/new_term"] = sinon.stub()
      Coreon.Views.MyView.nestedFieldsFor "terms"

    describe "removeTerm()", ->
      
      beforeEach ->
        @view.$el.append '''
          <fieldset id="first" class="term">
            <a class="remove-term">Remove term</a>
          </fieldset>
          <fieldset id="second" class="term">
            <a class="remove-term">Remove term</a>
            <input type="hidden" name="concept[terms][42][_id]">
          </fieldset>
          '''
        @event = $.Event "click"

      it "removes fields of non-existing term", ->
        @event.target = @view.$("#first .remove-term")[0]
        @view.removeTerm @event
        @view.$el.should.not.have "#first"
        @view.$el.should.have "#second"

      it "marks fields of existing term as deleted", ->
        @event.target = @view.$("#second .remove-term")[0]
        @view.removeTerm @event
        @view.$el.should.have "#first"
        @view.$el.should.have "#second"
        @view.$('#second').should.have.class "delete"

    describe "addTerm()", ->

      beforeEach ->
        Coreon.Templates["terms/new_term"].reset()
        @view.$el.append '''
          <div class="terms">
            <h3>TERMS</h3>
            <div class="edit">
              <a class="add-term">Add term</a>
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
        @view.$(".term").next().should.match ".edit"

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

  context "with custom options", ->
     
    before ->
      Coreon.Views.MyView.nestedFieldsFor "properties",
        className: "term-property"
        template: -> '<fieldset class="term-property"></fieldset>'
        as: "TermProperty"

    describe "removeTermProperty()", ->
      
      beforeEach ->
        @view.$el.append '''
          <fieldset class="term-property">
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
