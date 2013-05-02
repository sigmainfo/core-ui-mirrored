#= require environment
#= require views/composite_view
#= require templates/terms/term
#= require templates/shared/info
#= require views/properties/properties_view
#= require models/concept
#= require helpers/render

class Coreon.Views.Terms.TermView extends Coreon.Views.CompositeView

  className: "term"

  template: Coreon.Templates["terms/term"]

  events:
    "click .system-info-toggle": "toggleInfo"

  render: ->
    @$el.html @template
      term: @options.term
    if @options.term.get("properties")?.length
      @append new Coreon.Views.Properties.PropertiesView
        properties: @options.term.get("properties")
        collapsed: true
    super

  toggleInfo: (event) ->
    event.stopPropagation()
    @$(".system-info").slideToggle()

