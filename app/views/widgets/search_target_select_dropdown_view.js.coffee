#= require environment
#= require views/simple_view
#= require templates/widgets/search_target_select_dropdown
#= require jquery.ui.position

KEYCODE =
  esc: 27
  enter: 13
  down: 40
  up: 38

class Coreon.Views.Widgets.SearchTargetSelectDropdownView extends Backbone.View

  id: "coreon-search-target-select-dropdown"

  template: Coreon.Templates["widgets/search_target_select_dropdown"]

  events:
    "click": "onClick"
    "click li": "onSelect"
    "mouseover li": "onFocus"
    "mouseout li": "onBlur"

  initialize: ->
    $(document).keydown @onKeydown
    $(window).off "resize"
    $(window).resize @onResize

  render: ->
    @$el.html @template
      options: @model.get "availableTypes"
      selected: @model.get "selectedTypeIndex"
    @

  alignTo: (parent) ->
    @parent = parent
    @$("ul")
      .width( parent.outerWidth() - 1 )
      .position(
        my: "left+1 top"
        at: "left bottom"
        of: parent
      )

  onClick: (event) ->
    @remove()

  onSelect: (event) ->
    @model.set "selectedTypeIndex", $(event.target).index()

  onFocus: (event) =>
    @$("li.option.focus").removeClass "focus"
    $(event.target).addClass "focus"

  onBlur: (event) =>
    @$("li.option.focus").removeClass "focus"

  onKeydown: (event) =>
    focusedTypeIndex = @$("li.option.focus").index()
    switch event.keyCode
      when KEYCODE.esc
        @remove()
      when KEYCODE.enter
        @remove()
        if focusedTypeIndex > -1
          @model.set "selectedTypeIndex", focusedTypeIndex
      when KEYCODE.down
        focusedTypeIndex++ unless focusedTypeIndex >= (@model.get("availableTypes").length - 1)
        @$("li.option.focus").removeClass "focus"
        @$("li.option").eq(focusedTypeIndex).addClass "focus"
      when KEYCODE.up
        focusedTypeIndex-- unless focusedTypeIndex <= 0
        @$("li.option.focus").removeClass "focus"
        @$("li.option").eq(focusedTypeIndex).addClass "focus"


  onResize: (event) =>
    @alignTo @parent if @parent
