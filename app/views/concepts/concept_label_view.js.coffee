#= require environment
#= require views/simple_view
#= require models/concept

class Coreon.Views.Concepts.ConceptLabelView extends Coreon.Views.SimpleView

  tagName: "a"

  className: "concept-label"

  initialize: (idOrOptions) ->
    switch typeof idOrOptions
      when "string"
        @model = Coreon.Models.Concept.find idOrOptions
      when "object"
        @model = idOrOptions.model

    @model.on "change"     , @render       , @
    @model.on "hit:add"    , @_onHitAdd    , @
    @model.on "hit:remove" , @_onHitRemove , @

  appendTo: (target) ->
    @delegateEvents()
    @$el.appendTo target

  dispose: ->
    @model.off null, null, @

  destroy: ->
    @remove()
    @dispose()

  render: ->
    @$el.attr "href", "/concepts/#{@model.id}"
    @$el.html @model.label()
    @

  _onHitAdd: ->
    @$el.addClass "hit"

  _onHitRemove: ->
    @$el.removeClass "hit"
