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
    _(@collection).each (relation) =>
      if !@editing
        relationView = new Coreon.Views.Concepts.Shared.AssociativeRelations.ShowView model: relation
      else
        relationView = new Coreon.Views.Concepts.Shared.AssociativeRelations.EditView model: relation
      @relationViews.push relationView

      @$el.find('table').append relationView.render().$el
    @