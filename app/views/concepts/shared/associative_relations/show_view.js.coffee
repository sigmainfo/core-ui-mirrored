#= require environment
#= require templates/concepts/shared/associative_relations/show

class Coreon.Views.Concepts.Shared.AssociativeRelations.ShowView extends Backbone.View

  tagName: "tr"

  className: "relation-type"

  template: Coreon.Templates["concepts/shared/associative_relations/show"]

  render: ->
    @$el.html @template relation: @model
    @