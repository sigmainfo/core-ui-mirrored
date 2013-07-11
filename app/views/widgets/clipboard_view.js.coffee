#= require environment
#= require collections/clips
#= require views/concepts/concept_label_view
#= require templates/widgets/clipboard

class Coreon.Views.Widgets.ClipboardView extends Backbone.View

  id: "coreon-clipboard"
  className: "widget"
  template: Coreon.Templates["widgets/clipboard"]

  _concept_label_views: []

  initialize: ->
    collection = Coreon.Collections.Clips.collection()
    @listenTo collection, "add", @onAddItem
    #@listenTo collection, "remove", @onRemoveItem
    @listenTo collection, "reset", @onResetItems

  onAddItem: (model, collection)->
    view = new Coreon.Views.Concepts.ConceptLabelView model:model
    @_concept_label_views.push view
    @render()

  #onRemoveItem: ->
  #  @render()

  onResetItems: (model, collection)->
    clip.remove() while clip = @_concept_label_views.pop()
    for clip in collection.models
      @_concept_label_views.push new Coreon.Views.Concepts.ConceptLabelView model:clip
    @render()

  render: ->
    @$el.html @template()
    ul = @$("ul")
    for clip in @_concept_label_views
      ul.append $('<li>').append clip.render().$el
    @

