#= require environment

class Coreon.Views.CompositeView extends Backbone.View

  initialize: ->
    @subviews = []

  render: ->
    @renderSubviews()
    @

  renderSubviews: (models = @model.models) ->
    @removeSubviews()
    subviews = @createSubviews models
    _(subviews).invoke 'render'
    @insertSubviews subviews
    subviews

  removeSubviews: (subviews = @subviews)->
    _(subviews).invoke 'remove'
    @subviews = _(@subviews).difference subviews

  createSubviews: (models = @model.models) ->
    subviews = models.map @createSubview
    @subviews = _(@subviews).union subviews
    subviews

  createSubview: (model) ->
    new Backbone.View model: model

  insertSubviews: (subviews = @subviews) ->
    subviews.forEach _(@insertSubview).bind @

  insertSubview: (subview) ->
    @$el.append subview.el
