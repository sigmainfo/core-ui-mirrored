#= require environment
#= require helpers/repository_path
#= require helpers/can
#= require templates/concepts/shared/broader_and_narrower
#= require templates/repositories/repository_label
#= require views/concepts/concept_label_view
#= require models/concept
#= require models/notification
#= require modules/droppable
#= require helpers/form_for

class Coreon.Views.Concepts.Shared.BroaderAndNarrowerView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Droppable

  tagName: "section"

  className: "broader-and-narrower"

  template: Coreon.Templates["concepts/shared/broader_and_narrower"]
  repositoryLabel: Coreon.Templates["repositories/repository_label"]

  events:
    "click  .submit .cancel":   "cancelConceptConnections"
    "click  .submit .reset":    "resetConceptConnections"
    "submit  form":             "updateConceptConnections"
    "click   .concept-label":   "preventLabelClicks"
    "click  .edit-connections": "toggleEditMode"

  concepts: null

  initialize: ->
    @broader = []
    @narrower = []
    @_bindChangeEvents()

  _bindChangeEvents: ->
    @listenTo @model, "change:label", @renderSelf
    @listenTo @model, "change:super_concept_ids nonblank", =>
      _.defer => @renderBroader()
    @listenTo @model, "change:sub_concept_ids", =>
      _.defer => @renderNarrower()

  render: ->
    @$el.html @template model: @model, editable: !@model.isNew(), editMode: @editMode

    if @editMode
      @activateDropzones()
      $(window).on "keydown.coreonSubmit", (evt) =>
        if evt.keyCode is 13 and $(":focus").length == 0 or $(":focus").parents(".broader-and-narrower").length == 1
          @$("form").submit()
    else
      @deactivateDropzones()
      $(window).off ".coreonSubmit"

    @renderSelf()
    @renderBroader()
    @renderNarrower()
    @

  activateDropzones: ->
    @droppableOn @$(".broader.ui-droppable ul"), "ui-droppable-connect",
      accept: (item)=> @dropItemAcceptance(item)
      drop: (evt, ui)=> @onDrop("broader", ui.draggable)
      over: (evt, ui)=> @onDropOver(evt, ui)
      out: (evt, ui)=> @onDropOut(evt, ui)
    @droppableOn @$(".narrower.ui-droppable ul"), "ui-droppable-connect",
      accept: (item)=> @dropItemAcceptance(item)
      drop: (evt, ui)=> @onDrop("narrower", ui.draggable)
      over: (evt, ui)=> @onDropOver(evt, ui)
      out: (evt, ui)=> @onDropOut(evt, ui)

    @droppableOn @$(".list"), "ui-droppable-disconnect",
      accept: (item)-> $(item).hasClass "from-connection-list"
      drop: (evt, ui)=> @onDisconnect(ui.draggable)

  deactivateDropzones: ->
    @droppableOff(el) for el in @$(".ui-droppable") if $(el).data("uiDroppable")


  renderSelf: ->
    @$(".self").html @model.escape "label"
    @$(".self").attr "data-drag-ident", @model.get("_id")

  renderBroader: ->
    @clearBroader()
    super_concept_ids = @model.get "super_concept_ids"
    if super_concept_ids.length > 0
      @broader = @renderConcepts @$(".broader ul"), super_concept_ids
    else unless @model.blank or @editMode
      @$(".broader ul").html "<li>#{@repositoryLabel repository: Coreon.application.get("session").currentRepository()}</li>"

  renderNarrower: ->
    @clearNarrower()
    @narrower = @renderConcepts @$(".narrower ul"), @model.get "sub_concept_ids"

  renderConcepts: (container, ids) ->
    container.empty()
    concepts = ( @createConcept id for id in ids )
    for concept in concepts
      concept_el = concept.render().$el
      concept_el.attr "data-drag-ident", concept.model.id
      concept_el.addClass "from-connection-list"
      container.append $("<li>").append concept_el
    concepts

  createConcept: (id) ->
    concept = new Coreon.Views.Concepts.ConceptLabelView
      model: Coreon.Models.Concept.find id
    concept

  remove: ->
    @clearBroader()
    @clearNarrower()
    super

  clearBroader: ->
    concept.remove() while concept = @broader.pop()

  clearNarrower: ->
    concept.remove() while concept = @narrower.pop()

  dropItemAcceptance: (item)->
    true

  onDropOver: (evt, ui)->
    ident = $(ui.draggable.context).attr("data-drag-ident")
    if @model.acceptsConnection(ident)
      $(ui.helper).addClass "ui-droppable-connect"
    else
      $(ui.draggable.context).draggable "option", "revert", true
      $(evt.target).removeClass "ui-state-hovered"

  onDropOut: (evt, ui)->
    ident = $(ui.helper).data("drag-ident")
    $(ui.helper).removeClass "ui-droppable-connect"
    $(ui.draggable.context).draggable "option", "revert", "invalid"

  onDrop: (broaderNarrower, item)->
    ident = item.data("drag-ident")
    return false unless @model.acceptsConnection(ident)

    if broaderNarrower is "broader"
      conceptIds = (id for id in @model.get("super_concept_ids"))
      conceptIds.push(ident)
      @model.set "super_concept_ids", conceptIds
    else
      conceptIds = (id for id in @model.get("sub_concept_ids"))
      conceptIds.push(ident)
      @model.set "sub_concept_ids", conceptIds

  onDisconnect: (item)->
    ident = item.data("drag-ident")
    broader = @model.get "super_concept_ids"
    narrower = @model.get "sub_concept_ids"
    @model.set "super_concept_ids", _.without broader, ident if ident in broader
    @model.set "sub_concept_ids", _.without narrower, ident if ident in narrower

  resetConceptConnections: (evt) ->
    evt.preventDefault()
    evt.stopPropagation()
    @model.resetConceptConnections()

  cancelConceptConnections: (evt) ->
    @resetConceptConnections(evt)
    @toggleEditMode()

  updateConceptConnections: (evt) ->
    evt.preventDefault()
    evt.stopPropagation()

    @$("form, .submit a").addClass "disabled"
    @$(".submit button").prop "disabled", true

    data =
      super_concept_ids: @model.get("super_concept_ids")
      sub_concept_ids: @model.get("sub_concept_ids")

    @model.save data,
      success: =>
        Coreon.Models.Notification.info I18n.t("notifications.concept.broader_added", count: 42, label: "example")
        Coreon.Models.Notification.info I18n.t("notifications.concept.narrower_added", count: 42, label: "example")
        Coreon.Models.Notification.info I18n.t("notifications.concept.broader_deleted", count: 42, label: "example")
        Coreon.Models.Notification.info I18n.t("notifications.concept.narrower_deleted", count: 42, label: "example")
        @toggleEditMode()

      attrs:
        concept: data


  toggleEditMode: ->
    @editMode = !@editMode
    if @editMode
      @model = new Coreon.Models.BroaderAndNarrowerForm {}, concept: @model
    else
      @model = @model.concept

    @_bindChangeEvents()
    @render()

  preventLabelClicks: (evt)->
    if @editMode
      evt.preventDefault()
      evt.stopPropagation()
