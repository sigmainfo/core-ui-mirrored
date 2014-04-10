#= require environment
#= require templates/terms/term
#= require views/properties/properties_view

class Coreon.Views.Terms.TermView extends Backbone.View

  tagName: 'li'

  className: 'term'

  initialize: (options = {}) ->
    _(options).defaults
      template: Coreon.Templates['terms/term']

    @template = options.template
    @subviews = []

    @stopListening()
    @listenTo @model, 'change', @render

  render: ->
    @subviews.forEach (subview) ->
      subview.remove()
    @subviews = []

    @$el.html @template
      value : @model.get('value')
      info  : @model.info()

    if @model.hasProperties()
      propertiesView = new Coreon.Views.Properties.PropertiesView
        model: @model.publicProperties()
      propertiesView.render()
      @$el.append propertiesView.$el

    @
