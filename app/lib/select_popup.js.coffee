#= require environment

KEYCODE =
  esc:   27
  enter: 13
  down:  40
  up:    38

class Coreon.Lib.SelectPopup extends Backbone.View

  #Coreon.Modules.include @, Coreon.Modules.Prompt

  className: "coreon-select-dropdown"

  events:
    "click"        : "remove"
    "click li"     : "onItemClick"
    "mouseover li" : "onItemFocus"
    "mouseout li"  : "onItemBlur"

  initialize: ->
    @widget = @options.widget
    @value = @options.value
    @selectOptions = @options.selectOptions

  render: ->
    list = $("<ul class='options'>")
    @$el.append list
    @$el.addClass @options.widgetClasses

    for option in @selectOptions
      item = $("<li class='option' data-value='#{option[0]}'><span>#{option[1]}</span></li>")

      item.addClass('selected') if option[0] == @value
      list.append item

    $(document).off ".coreonSelectPopup"
    $(document).on 'keydown.coreonSelectPopup', @onKeydown

    @

  remove: ->
    super
    $(document).off ".coreonSelectPopup"
    @

  setItem: (elem) ->
    @widget.changeTo elem.data('value'), elem.text()
    @

  focusItem: (elem) ->
    @$("li.option.focus").removeClass "focus"
    if elem?.length > 0
      elem.addClass "focus"
    @

  onItemClick: (e) ->
    el = $(e.target).closest('li')
    @setItem el

  onItemFocus: (e) ->
    @focusItem $(e.target).closest("li")

  onItemBlur: (e) ->
    @focusItem false

  onKeydown: (e) =>
    current = @$("li.option.focus").first()
    switch e.keyCode
      when KEYCODE.esc
        @remove()
      when KEYCODE.enter
        @remove()
        if current.length > 0
          @setItem current
      when KEYCODE.down
        if current.length > 0
          next = current.next()
          if next.length > 0
            @focusItem next
        else
          @focusItem @$("li.option").first()
      when KEYCODE.up
        if current.length > 0
          prev = current.prev()
          if prev.length > 0
            @focusItem prev
        else
          @focusItem @$("li.option").last()
