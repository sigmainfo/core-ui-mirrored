#= require environment
#= require views/concepts/concept_label_view

class Coreon.Views.Concepts.ConceptLabelListView extends Backbone.View

  subviews: null

  initialize: (options = {}) ->
    @clearSubviews()
    @stopListening()

    @model = new Backbone.Collection options.models
    @listenTo @model
            , 'change:label'
            , @render

  clearSubviews: ->
    @subviews?.forEach (view) -> view.remove()
    @subviews = []

  insertLabel: (concept) ->
    label = new Coreon.Views.Concepts.ConceptLabelView
      model: concept
    label.render()
    @subviews.push label
    @$el.append label.$el

  sorted: ->
    Coreon.Modules.Collation.sortBy 'label', @model.models

  render: ->
    @clearSubviews()
    @$el.html ''

    @sorted().forEach (concept) => @insertLabel concept

    @
