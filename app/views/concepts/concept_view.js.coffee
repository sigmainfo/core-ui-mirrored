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
#= require templates/concepts/_term
#= require templates/terms/new_term
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
  editTerm: no

  template: Coreon.Templates["concepts/concept"]
  term:     Coreon.Templates["terms/new_term"]

  @nestedFieldsFor "properties", name: "property"

  events:
    "click  .edit-concept"                       : "toggleEditMode"
    "click  *:not(.terms) .edit-properties"      : "toggleEditConceptProperties"
    "click  .system-info-toggle"                 : "toggleInfo"
    "click  section:not(form *) > *:first-child" : "toggleSection"
    "click  .properties .index li"               : "selectProperty"
    "click  .add-property"                       : "addProperty"
    "click  .remove-property"                    : "removeProperty"
    "click  .add-term"                           : "addTerm"
    "click  .remove-term"                        : "removeTerm"
    "submit form.concept.update"                 : "updateConceptProperties"
    "submit form.term.create"                    : "createTerm"
    "submit form.term.update"                    : "updateTerm"
    "click  form a.cancel:not(.disabled)"        : "cancelForm"
    "click  form a.reset:not(.disabled)"         : "reset"
    "click  .edit-term"                          : "toggleEditTerm"
    "click  .delete-concept"                     : "delete"
    "click  form.concept.update .submit .cancel" : "toggleEditConceptProperties"
    "click  form.term.update .submit .cancel"    : "toggleEditTerm"

  initialize: ->
    @broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: @model
    @listenTo @model, "change", @render

  render: ->
    @$el.html @template
      concept: @model,
      editMode: @editMode,
      editProperties: @editProperties,
      editTerm: @editTerm

    @broaderAndNarrower.render() unless @_wasRendered
    @$el.children(".system-info").after @broaderAndNarrower.$el
    @_wasRendered = true
    @

  toggleInfo: (evt) ->
    target = $ evt.target
    target.next(".system-info")
      .add( target.siblings(".properties").find ".system-info" )
      .slideToggle()

  toggleSection: (evt) ->
    target = $(evt.target)
    target.closest("section").toggleClass "collapsed"
    target.siblings().not(".edit").slideToggle()

  selectProperty: (evt) ->
    target = $ evt.target
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

  toggleEditConceptProperties: (evt)->
    evt.preventDefault() if evt?
    @editProperties = !@editProperties
    @render()

  toggleEditTerm: (evt) ->
    if evt?
      evt.preventDefault()
      term_id = $(evt.target).data("id")
      @editTerm = if @editTerm == term_id then no else term_id
    else
      @editTerm = !@editTerm

    @render()

  addTerm: ->
    terms = @$(".terms")
    terms.children(".edit").hide()
    terms.append @term term: new Coreon.Models.Term

  saveConceptProperties: (attrs) ->
    @model.save attrs,
      success: =>
        @toggleEditConceptProperties()
      error: (model) =>
        model.once "error", @render, @
      attrs:
        concept: attrs

  updateConceptProperties: (evt) ->
    evt.preventDefault()
    form = $ evt.target
    data = form.serializeJSON().concept or {}
    attrs = {}
    attrs.properties = if data.properties?
      property for property in data.properties when property?
    else []
    form
      .find("input,textarea,button")
        .prop("disabled", true)
      .end()
      .find("a")
        .addClass("disabled")
    trigger = form.find('[type=submit]')
    elements_to_delete = form.find(".property.delete")

    if elements_to_delete.length > 0
      @confirm
        trigger: trigger
        message: I18n.t "concept.confirm_update", n: elements_to_delete.length
        action: =>
          @saveConceptProperties attrs
    else
      @saveConceptProperties attrs

  updateTerm: (evt) ->
    evt.preventDefault()
    form = $ evt.target
    data = form.serializeJSON()?.term or {}
    data._id = form.find("input[name=id]").val()
    data.properties = if data.properties?
      property for property in data.properties when property?
    else []

    form
      .find("input,textarea,button")
        .prop("disabled", true)
      .end()
      .find("a")
        .addClass("disabled")
    trigger = form.find('[type=submit]')
    elements_to_delete = form.find(".property.delete")

    if elements_to_delete.length > 0
      @confirm
        trigger: trigger
        message: I18n.t "term.confirm_update", {n:elements_to_delete.length}
        action: =>
          @saveTerm(data)
    else
      @saveTerm(data)

    form.find("[type=submit]").attr "disabled", false
    false


  saveTerm: (data)->
    model = @model.terms().get data._id
    console.log model, data
    model.save data,
      success: => @toggleEditTerm()
      error: (model)=>
        model.once "error", @render, @
      attrs: term: data


  createTerm: (evt) ->
    evt.preventDefault()
    target = $ evt.target
    data = target.serializeJSON().term or {}
    data.concept_id = @model.id
    data.properties = if data.properties?
      property for property in data.properties when property?
    else []

    target
      .find("input,textarea,button")
        .prop("disabled", true)
      .end()
      .find("a")
        .addClass("disabled")
        
    @model.terms().create data,
      wait: true
      error: (model, xhr, options) =>
        model.once "error", =>
          @$("form.term.create").replaceWith @term term: model

  cancelForm: (evt) ->
    evt.preventDefault()
    if @model.remoteError?
      @model.set @model.previousAttributes()
      @model.remoteError = null
    form = $(evt.target).closest "form"
    form.siblings(".edit").show()
    form.remove()

  reset: (evt) ->
    evt.preventDefault()
    @model.attributes = @model._previousAttributes
    @model.remoteError = null
    @render()

  removeTerm: (evt) =>
    trigger = $ evt.target
    container = trigger.closest ".term"
    model = @model.terms().get trigger.data "id"
    @confirm
      trigger: trigger
      container: container
      message: I18n.t "term.confirm_delete"
      action: ->
        container.remove()
        model.destroy()

  delete: (evt) ->
    trigger = $ evt.target
    @confirm
      trigger: trigger
      container: trigger.closest ".concept"
      message: I18n.t "concept.confirm_delete"
      action: =>
        @model.destroy()
        Backbone.history.navigate "/", trigger: true
