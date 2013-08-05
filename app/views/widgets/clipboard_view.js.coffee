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
    @listenTo @collection, "add", @onAddItem
    #@listenTo @collection, "remove", @onRemoveItem
    @listenTo @collection, "reset", @onResetItems

  onAddItem: (model, collection)->
    view = new Coreon.Views.Concepts.ConceptLabelView model:model
    @_concept_label_views.push view
    @render()

  #onRemoveItem: ->
  #  @render()

  onResetItems: (model, collection)->
    @collection ||= Coreon.Collections.Clips.collection()
    clip.remove() while clip = @_concept_label_views.pop()
    for clip in @collection.models
      @_concept_label_views.push new Coreon.Views.Concepts.ConceptLabelView model:clip
    @render()

  dropItemAcceptance: (el)->
    @collection ||= Coreon.Collections.Clips.collection()
    id = el.attr "id"
    id? && !@collection._byId[id]?

  onDropItem: (evt, drop)->
    @collection ||= Coreon.Collections.Clips.collection()
    id = drop.draggable.attr("id")
    model = Coreon.Models.Concept.find id
    @collection.add model

  render: ->
    @$el.droppable
      accept: @dropItemAcceptance
      activeClass: "ui-state-highlight"
      tolerance: "pointer"

    @$el.html @template()
    ul = @$("ul")
    for clip in @_concept_label_views
      ul.append $('<li>').append clip.render().$el
    @

  clear: ->
    @collection ||= Coreon.Collections.Clips.collection()
    @collection.reset []
