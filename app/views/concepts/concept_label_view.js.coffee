#= require environment
#= require views/simple_view
#= require models/concept

class Coreon.Views.Concepts.ConceptLabelView extends Coreon.Views.SimpleView

  tagName: "a"

  className: "concept-label"

  initialize: (options = {}) ->
    @model =  if options.model?
        options.model
      else
        Coreon.Models.Concept.find options.id

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
    @$el.toggleClass "hit", @model.hit()
    @$el.attr "href", "/concepts/#{@model.id}"
    @$el.html @model.label()
    @

  _onHitAdd: ->
    @$el.addClass "hit"

  _onHitRemove: ->
    @$el.removeClass "hit"
