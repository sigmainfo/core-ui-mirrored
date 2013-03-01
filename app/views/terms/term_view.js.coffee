#= require environment
#= require views/composite_view
#= require templates/terms/term
#= require templates/layout/info
#= require views/properties/properties_view
#= require models/concept

class Coreon.Views.Terms.TermView extends Coreon.Views.CompositeView

  className: "term"

  template: Coreon.Templates["terms/term"]
  info: Coreon.Templates["layout/info"]

  events:
    "click .system-info-toggle": "toggleInfo"

  render: ->
    @$el.html @template
      value: @options.term.get("value")
      info: @info(data: @options.term.info())
    if @options.term.get("properties")?.length
      @append new Coreon.Views.Properties.PropertiesView
        properties: @options.term.get("properties")
        collapsed: true
    super

  toggleInfo: (event) ->
    event.stopPropagation()
    @$(".system-info").slideToggle()

