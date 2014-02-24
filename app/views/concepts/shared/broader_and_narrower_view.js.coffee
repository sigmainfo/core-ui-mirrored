#= require environment
#= require helpers/repository_path
#= require helpers/can
#= require templates/concepts/shared/broader_and_narrower
#= require templates/repositories/repository_label
#= require views/concepts/concept_label_view
#= require models/concept
#= require models/notification
#= require modules/droppable
#= require modules/draggable
#= require helpers/form_for

class Coreon.Views.Concepts.Shared.BroaderAndNarrowerView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Droppable
  Coreon.Modules.include @, Coreon.Modules.Draggable

  tagName: "section"

  className: "broader-and-narrower"

  template: Coreon.Templates["concepts/shared/broader_and_narrower"]
  repositoryLabel: Coreon.Templates["repositories/repository_label"]

  events:
    "click  .submit .cancel:not(.disabled)" : "cancelConceptConnections"
    "click  .submit .reset:not(.disabled)"  : "resetConceptConnections"
    "submit  form"                          : "updateConceptConnections"
    "click  .concept-label"                 : "preventLabelClicks"
    "click  .edit-connections"              : "toggleEditMode"

  concepts: null

  initialize: ->
    @broader = []
    @narrower = []
    @_bindChangeEvents()

  _bindChangeEvents: ->
    @listenTo @model, "change:label", @renderSelf
    @listenTo @model, "change:superconcept_ids nonblank", =>
      _.defer => @renderBroader()
    @listenTo @model, "change:subconcept_ids", =>
      _.defer => @renderNarrower()

  render: ->
    @$el.html @template model: @model, editable: !@model.isNew(), editing: @editing

    if @editing
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
    @droppableOn @$(".broader ul"), "ui-droppable-connect",
      accept: (item)=> @dropItemAcceptance(item)
      drop: (evt, ui)=> @onDrop("broader", ui.draggable)
      over: (evt, ui)=> @onDropOver(evt, ui)
      out: (evt, ui)=> @onDropOut(evt, ui)
    @droppableOn @$(".narrower ul"), "ui-droppable-connect",
      accept: (item)=> @dropItemAcceptance(item)
      drop: (evt, ui)=> @onDrop("narrower", ui.draggable)
      over: (evt, ui)=> @onDropOver(evt, ui)
      out: (evt, ui)=> @onDropOut(evt, ui)

    @droppableOn @$(".list"), "ui-droppable-disconnect",
      accept: (item)-> $(item).hasClass "from-connection-list"
      drop: (evt, ui)=> @onDisconnect(ui.draggable)

  deactivateDropzones: ->
    @droppableOff(el) for el in @$(".ui-droppable")


  renderSelf: ->
    @$(".self").html @model.escape "label"
    @$(".self").attr "data-drag-ident", @model.get("id")

  renderBroader: ->
    @clearBroader()
    superconcept_ids = @model.get "superconcept_ids"
    if superconcept_ids.length > 0
      @broader = @renderConcepts @$(".broader ul"), superconcept_ids
    else unless @model.blank or @editing
      @$(".broader ul").html "<li>#{@repositoryLabel repository: Coreon.application.get("session").currentRepository()}</li>"

  renderNarrower: ->
    @clearNarrower()
    @narrower = @renderConcepts @$(".narrower ul"), @model.get "subconcept_ids"

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
      conceptIds = (id for id in @model.get("superconcept_ids"))
      conceptIds.push(ident)
      @model.set "superconcept_ids", conceptIds
    else
      conceptIds = (id for id in @model.get("subconcept_ids"))
      conceptIds.push(ident)
      @model.set "subconcept_ids", conceptIds

  onDisconnect: (item)->
    ident = item.data("drag-ident")
    broader = @model.get "superconcept_ids"
    narrower = @model.get "subconcept_ids"
    @model.set "superconcept_ids", _.without broader, ident if ident in broader
    @model.set "subconcept_ids", _.without narrower, ident if ident in narrower

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
    $(el).draggable "disable" for el in @$("form .ui-draggable")
    $(el).droppable "disable" for el in @$("form .ui-droppable")

    data =
      superconcept_ids: @model.get("superconcept_ids")
      subconcept_ids: @model.get("subconcept_ids")

    addedBroaderConcepts = (Coreon.Models.Concept.find(id).get("label") for id in @model.addedBroaderConcepts())
    addedNarrowerConcepts = (Coreon.Models.Concept.find(id).get("label") for id in @model.addedNarrowerConcepts())
    removedBroaderConcepts = (Coreon.Models.Concept.find(id).get("label") for id in @model.removedBroaderConcepts())
    removedNarrowerConcepts = (Coreon.Models.Concept.find(id).get("label") for id in @model.removedNarrowerConcepts())

    deferred = @model.save data, attrs: {concept: data}, wait: true
    deferred.done =>
      if addedBroaderConcepts.length > 0
        Coreon.Models.Notification.info I18n.t("notifications.concept.broader_added", count: addedBroaderConcepts.length, label: addedBroaderConcepts[0])
      if addedNarrowerConcepts.length > 0
        Coreon.Models.Notification.info I18n.t("notifications.concept.narrower_added", count: addedNarrowerConcepts.length, label: addedNarrowerConcepts[0])

      if removedBroaderConcepts.length > 0
        Coreon.Models.Notification.info I18n.t("notifications.concept.broader_deleted", count: removedBroaderConcepts.length, label: removedBroaderConcepts[0])
      if removedNarrowerConcepts.length > 0
        Coreon.Models.Notification.info I18n.t("notifications.concept.narrower_deleted", count: removedNarrowerConcepts.length, label: removedNarrowerConcepts[0])

      @toggleEditMode()

    deferred.fail =>
      @$("form, .submit a").removeClass "disabled"
      @$(".submit button").prop "disabled", false
      $(el).draggable "enable" for el in @$("form .ui-draggable")
      $(el).droppable "enable" for el in @$("form .ui-droppable")


  toggleEditMode: ->
    @editing = !@editing
    if @editing
      @model = new Coreon.Models.BroaderAndNarrowerForm {}, concept: @model
    else
      @model = @model.concept

    @_bindChangeEvents()
    @render()
    @draggableOn @$(".self")

  preventLabelClicks: (evt)->
    if @editing
      evt.preventDefault()
      evt.stopPropagation()
