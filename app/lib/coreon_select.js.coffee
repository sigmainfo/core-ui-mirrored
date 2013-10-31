#= require environment
#= require modules/helpers
#= require modules/prompt
#= require jquery.ui.position

KEYCODE =
  esc: 27
  enter: 13
  down: 40
  up: 38

$ = jQuery

$.fn.extend
  coreonSelect: (options) ->
    this.each (input_field) ->
      $this = $ this
      coreonSelect= $this.data('coreonSelect')
      if options is 'destroy' && coreonSelect
        coreonSelect.destroy()
      else unless coreonSelect
        $this.data('coreonSelect', new CoreonSelect(this, options))

      return

class CoreonSelectPopup extends Backbone.View
  
  Coreon.Modules.include @, Coreon.Modules.Prompt
   
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
    @$el.addClass @widget.$select.attr('class')
    
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
    if elem?
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

class CoreonSelect
  
  Coreon.Modules.include @, Coreon.Modules.Prompt
  
  constructor: (@formField, @options={}) ->
    selectOptions = []
    @$select = $ @formField
    
    selected = $("option[value=#{@$select.val()}]", @$select).first()
    selected = $("option", @$select).first() if selected.length == 0
    
    @$el = $ "<div class='coreon-select'>#{selected.text()}</div>"
    @$el.attr('data-select-name', @$select.attr('name'))
    @$el.addClass(@$select.attr('class'))
      
    
    $('option', @$select).each (i) ->
      $option = $ this
      selectOptions.push [$option.val(), $option.text()]
      
    @selectOptions = selectOptions
      
    if @selectOptions.length < 2
      @$el.addClass('single')
    else
      @$el.click @showDropdown
      
    @$select.hide().after @$el
    
  changeTo: (val, label) =>
    @$el.text(label)
    @$select.val(val).change()
    @
    
  showDropdown: (e) =>
    view = new CoreonSelectPopup 
      widget: @
      value: @$select.val()
      selectOptions: @selectOptions
    
    @prompt view
    
    view.$('ul').position
      my: "left top"
      at: "left bottom"
      of: $ @$el   
    
    @