#= require environment
#= require helpers/render
#= require helpers/can
#= require helpers/form_for
#= require helpers/input
#= require templates/concepts/concept
#= require templates/concepts/_caption
#= require templates/concepts/_info
#= require templates/concepts/_properties
#= require templates/concepts/_edit_properties
#= require templates/terms/new_term
#= require templates/properties/new_property
#= require templates/properties/new_property
#= require views/concepts/shared/broader_and_narrower_view
#= require modules/helpers
#= require modules/nested_fields_for
#= require modules/confirmation
#= require jquery.serializeJSON

class Coreon.Views.Concepts.ConceptView extends Backbone.View

  Coreon.Modules.extend @, Coreon.Modules.NestedFieldsFor

  Coreon.Modules.include @, Coreon.Modules.Confirmation

  className: "concept show"
  editMode: no
  editProperties: no

  template: Coreon.Templates["concepts/concept"]
  term:     Coreon.Templates["terms/new_term"]

  @nestedFieldsFor "properties", name: "property"

  events:
    "click  .edit-concept"                       : "toggleEditMode"
    "click  *:not(.terms) .edit-properties"      : "toggleEditConceptProperties"
    "click  .system-info-toggle"                 : "toggleInfo"
    "click  section:not(form *) > *:first-child" : "toggleSection"
    "click  .properties .index li"               : "selectProperty"
    "click  .add-term"                           : "addTerm"
    "click  .add-property"                       : "addProperty"
    "click  .remove-property"                    : "removeProperty"
    "submit form.concept.update"                 : "updateConceptProperties"
    "submit form.term.create"                    : "createTerm"
    "click  form a.cancel"                       : "cancel"
    "click  .remove-term"                        : "removeTerm"
    "click  .edit .delete"                       : "delete"

  initialize: ->
    @broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: @model
    @listenTo @model, "change", @render

  render: ->
    @$el.html @template concept: @model, editMode: @editMode, editProperties: @editProperties
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
    target.siblings().not(".edit").slideToggle()

  selectProperty: (event) ->
    target = $ event.target
    container = target.closest "td"
    container.find("li.selected").removeClass "selected"
    container.find(".values > li").eq(target.data "index").add(target)
      .addClass "selected"

  toggleEditMode: ->
    @editMode = !@editMode
    if @editMode
      @$el.removeClass("show").addClass("edit")
    else
      @$el.removeClass("edit").addClass("show")

    @render()

  toggleEditConceptProperties: ->
    @editProperties = !@editProperties
    @render()

  addTerm: ->
    terms = @$(".terms")
    terms.children(".edit").hide()
    terms.append @term term: new Coreon.Models.Term

  updateConceptProperties: (event) ->
    event.preventDefault()
    target = $ event.target
    data = target.serializeJSON() or {}
    target.find("input,textarea,button").attr "disabled", true

    commit = =>
      @model.save data.concept,
        wait: true
        success: => @toggleEditConceptProperties()
        error: => @model.once "error", @render, @

    elements_to_delete = target.find(".property.delete")
    if elements_to_delete.length > 0
      @confirm
        trigger: target
        container: target.closest ".concept"
        message: I18n.t "concept.confirm_delete"
        action: =>
          commit()
    else
      commit()



  createTerm: (event) ->
    event.preventDefault()
    target = $ event.target
    data = target.serializeJSON().term or {}
    data.concept_id = @model.id
    data.properties = if data.properties?
      property for property in data.properties when property?
    else []
    target.find("input,textarea,button").attr "disabled", true
    @model.terms().create data,
      wait: true
      error: (model, xhr, options) =>
        model.once "error", =>
          @$("form.term.create").replaceWith @term term: model

  cancel: (event) ->
    event.preventDefault()
    form = $(event.target).closest "form"
    form.siblings(".edit").show()
    form.remove()

  removeTerm: (event) =>
    trigger = $ event.target
    container = trigger.closest ".term"
    model = @model.terms().get trigger.data "id"
    @confirm
      trigger: trigger
      container: container
      message: I18n.t "term.confirm_delete"
      action: ->
        container.remove()
        model.destroy()

  delete: (event) ->
    trigger = $ event.target
    @confirm
      trigger: trigger
      container: trigger.closest ".concept"
      message: I18n.t "concept.confirm_delete"
      action: =>
        @model.destroy()
        Backbone.history.navigate "/", trigger: true
