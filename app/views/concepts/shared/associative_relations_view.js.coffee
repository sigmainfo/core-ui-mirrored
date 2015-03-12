#= require environment
#= require templates/concepts/shared/associative_relations
#= require views/concepts/shared/associative_relations/show_view
#= require views/concepts/shared/associative_relations/edit_view

class Coreon.Views.Concepts.Shared.AssociativeRelationsView extends Backbone.View

  tagName: "section"

  className: "associative-relations"

  template: Coreon.Templates["concepts/shared/associative_relations"]

  initialize: (options) ->
    @editing = options.editing || no
    @collection = options.collection
    @relationViews = []

  render: ->
    @$el.html @template
    @collection.each (relation) =>
      if !@editing
        @relationViews.push new Coreon.Views.Concepts.Shared.AssociativeRelations.ShowView
      else
        @relationViews.push new Coreon.Views.Concepts.Shared.AssociativeRelations.EditView
    @