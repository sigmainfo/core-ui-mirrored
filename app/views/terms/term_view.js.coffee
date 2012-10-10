#= require environment
#= require views/composite_view
#= require templates/terms/term
#= require views/properties/properties_view

class Coreon.Views.Terms.TermView extends Coreon.Views.CompositeView

  className: "term"

  template: Coreon.Templates["terms/term"]

  render: ->
    @$el.html @template value: @options.term.value
    if @options.term.properties?.length
      @append new Coreon.Views.Properties.PropertiesView
        properties: @options.term.properties
        collapsed: true
    super
