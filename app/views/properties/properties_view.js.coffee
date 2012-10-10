#= require environment
#= require views/layout/section_view
#= require templates/properties/properties
#= require templates/properties/selector

class Coreon.Views.Properties.PropertiesView extends Coreon.Views.Layout.SectionView

  className: "properties"

  sectionTitle: -> I18n.t "properties.title"

  template: Coreon.Templates["properties/properties"]
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
    @$("ul.index").each (index, ul) =>
      @select target: $(ul).find("li a").get(0)
    @

  renderValues: (props) ->
    if props.length == 1 and not props[0].lang?
      props[0].value
    else
      @selector
        labels: (prop.lang or index + 1 for prop, index in props)
        values: (prop.value for prop in props)

  data: ->
    _(@options.properties or @model.get "properties").groupBy "key"

  select: (event) ->
    target = $(event.target)

    item = target.closest("li")
    item.siblings().removeClass "selected"
    item.addClass "selected"

    values = target.closest("td").find("ul.values li")
    index = target.attr "data-index"

    values.hide()
    values.eq(index).show()

