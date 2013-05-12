#= require environment
#= require helpers/render
#= require helpers/can
#= require helpers/form_for
#= require helpers/input
#= require templates/concepts/concept
#= require templates/concepts/_caption
#= require templates/concepts/_info
#= require templates/concepts/_properties
#= require templates/terms/new_term
#= require templates/properties/new_property
#= require views/concepts/shared/broader_and_narrower_view
#= require modules/helpers
#= require modules/nested_fields_for
#= require jquery.serializeJSON

class Coreon.Views.Concepts.ConceptView extends Backbone.View

  Coreon.Modules.extend @, Coreon.Modules.NestedFieldsFor

  className: "concept show"

  template: Coreon.Templates["concepts/concept"]
  term:     Coreon.Templates["terms/new_term"]

  @nestedFieldsFor "properties", name: "property"

  events:
    "click .system-info-toggle"                 : "toggleInfo"
    "click section:not(form *) > *:first-child" : "toggleSection"
    "click .properties .index li"               : "selectProperty"
    "click .add-term"                           : "addTerm"
    "click .add-property"                       : "addProperty"
    "click .remove-property"                    : "removeProperty"
    "submit form.term.create"                   : "createTerm"

  initialize: ->
    @broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: @model
    @listenTo @model, "change", @render

  render: ->
    @$el.html @template concept: @model
    @broaderAndNarrower.render() unless @_wasRendered
    @$el.children(".system-info").after @broaderAndNarrower.$el
    @_wasRendered = true
    @

  toggleInfo: (event) ->
    target = $ event.target
    target.next(".system-info")
      .add( target.siblings(".properties").find ".system-info" )
      .slideToggle()

  toggleSection: (event) ->
    target = $(event.target)
    target.closest("section").toggleClass "collapsed"
    target.next().slideToggle()

  selectProperty: (event) ->
    target = $ event.target
    container = target.closest "td"
    container.find("li.selected").removeClass "selected"
    container.find(".values > li").eq(target.data "index").add(target)
      .addClass "selected"

  addTerm: ->
    terms = @$(".terms")
    terms.find(".edit").hide()
    terms.append @term term: new Coreon.Models.Term

  createTerm: (event) ->
    event.preventDefault()
    target = $ event.target
    data = target.serializeJSON().term or {}
    data.concept_id = @model.id
    data.properties = if data.properties?
      property for property in data.properties when property?
    else []
    target.find("input,button").attr "disabled", true
    @model.terms().create data,
      wait: true
      error: (model, xhr, options) =>
        model.once "error", =>
          @$("form.term.create").replaceWith @term term: model
