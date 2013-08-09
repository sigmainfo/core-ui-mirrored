#= require environment
#= require jquery.ui.droppable
#= require collections/clips
#= require views/concepts/concept_label_view
#= require templates/widgets/clipboard

class Coreon.Views.Widgets.ClipboardView extends Backbone.View

  id: "coreon-clipboard"
  className: "widget"
  template: Coreon.Templates["widgets/clipboard"]

  events:
    "click .clear": "clear"
    "drop": "onDropItem"

  _concept_label_views: []

  initialize: ->
    @collection = Coreon.Collections.Clips.collection()
    @listenTo @collection, "add", @render
    #@listenTo @collection, "remove", @onRemoveItem
    @listenTo @collection, "reset", @render
    @$el.droppable
      accept: (el) => @dropItemAcceptance(el)
      activeClass: "ui-state-highlight"
      tolerance: "pointer"
      over: (evt, ui) => @onDropItemOver(evt, ui)
      out: (evt, ui) => @onDropItemOut(evt, ui)

  dropItemAcceptance: (item) ->
    not @collection.get item.data "drag-ident"

  onDropItem: (evt, ui) ->
    @$el.removeClass "ui-state-hovered"
    id = ui.draggable.data "drag-ident"
    model = Coreon.Models.Concept.find id
    @collection.add model

  onDropItemOver: (evt, ui) ->
    @$el.addClass "ui-state-hovered"
    ui.helper.addClass "ui-droppable-clipboard"

  onDropItemOut: (evt, ui) ->
    @$el.removeClass "ui-state-hovered"
    ui.helper.removeClass "ui-droppable-clipboard"

  render: ->
    clip.remove() while clip = @_concept_label_views.pop()

    @$el.html @template()
    ul = @$("ul")

    for clip in Coreon.Collections.Clips.collection().models
      view = new Coreon.Views.Concepts.ConceptLabelView model:clip
      ul.append $('<li>').append view.render().$el
    @

  clear: ->
    @collection.reset []
