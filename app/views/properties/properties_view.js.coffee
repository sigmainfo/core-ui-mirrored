#= require environment
#= require views/layout/section_view
#= require templates/properties/properties
#= require templates/properties/property
#= require templates/properties/selector
#= require templates/shared/info
#= require models/concept

class Coreon.Views.Properties.PropertiesView extends Coreon.Views.Layout.SectionView

  className: "properties"

  sectionTitle: -> I18n.t "properties.title"

  template: Coreon.Templates["properties/properties"]
  property: Coreon.Templates["properties/property"]
  info:     Coreon.Templates["shared/info"]
  selector: Coreon.Templates["properties/selector"]

  events:
    "click ul.index a": "select"

  render: ->
    super
    props = @data()
    keys = ( key for key of props )
    @$(".section").html @template keys: keys
    cells = @$("tr td")
    for key, index in keys
      cells.eq(index).html @renderValues props[key]
    @

  renderValues: (props) ->
    if props.length == 1 and not props[0].lang
      @renderProperty props[0]
    else
      @selector
        labels: (prop.lang or index + 1 for prop, index in props)
        properties: (@renderProperty(prop) for prop in props)

  renderProperty: (prop) ->
    idAttr = Coreon.Models.Concept::idAttribute
    internals = [idAttr, "key", "value", "lang"]
    data = _(id: prop[idAttr]).extend _(prop).omit internals
    @property
      value: prop.value
      info: @info(data: data)

  data: ->
    _(@options.properties or @model.get "properties").groupBy "key"

  select: (event) ->
    target = $(event.target)
    event.preventDefault()
    event.stopPropagation()

    item = target.closest("li")
    item.siblings().removeClass "selected"
    item.addClass "selected"

    values = target.closest("td").find("ul.values li")
    index = target.attr "data-index"

    values.hide()
    values.eq(index).show()


