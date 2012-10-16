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
      value: @options.term.value
      info: @info(data: @data())
    if @options.term.properties?.length
      @append new Coreon.Views.Properties.PropertiesView
        properties: @options.term.properties
        collapsed: true
    super

  data: ->
    term = @options.term
    idAttr = Coreon.Models.Concept::idAttribute
    _(id: term[idAttr]).extend _(term).omit idAttr, "value", "lang", "properties"

  toggleInfo: (event) ->
    event.stopPropagation()
    @$(".system-info").slideToggle()

