#= require environment
#= require modules/helpers
#= require modules/prompt
#= require jquery.ui.position

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

class CoreonSelect
  
  Coreon.Modules.include @, Coreon.Modules.Prompt
  
  constructor: (@formField, @options={}) ->
    selectOptions = []
    @$select = $ @formField
    @$el = $ "<div class='coreon-select'>#{$("option[value=#{@$select.val()}]", @$select).first().text()}</div>"
    
    $('option', @$select).each (i) ->
      $option = $ this
      selectOptions.push [$option.val(), $option.text()]
      
    @selectOptions = selectOptions
      
    if @selectOptions.length < 2
      @$el.addClass('single')
    else
      @$el.click @showDropdown
      
    @$select.hide().after @$el

  dropdownView: ->
    return @_dropdownView if @_dropdownView?
        
    list = $("<ul class='options'>")
    
    @_dropdownView = new Backbone.View
    @_dropdownView.$el = $("<div class='coreon-select-dropdown #{$(@formField).attr('class')}'>").append list
    @_dropdownView.render = -> 
      return @
    
    for option in @selectOptions
      item = $("<li class='option' data-value='#{option[0]}'><span>#{option[1]}</span></li>")        
      item.addClass('selected') if option[0] == @$select.val()
      list.append item
    
    $('li', list).on('mouseover', (e) =>
      @_dropdownView.$("li.option.focus",).removeClass "focus"
      $(e.target).closest("li").addClass "focus"
    ).on('mouseout', (e) =>
      @_dropdownView.$("li.option.focus", ).removeClass "focus"
    ).on('click', (e) =>
      el = $(e.target).closest('li')
      @changeTo(el.data('value'), el.text())
    )
    
    return @_dropdownView
    
  changeTo: (val, label) =>
    @$select.val(val)
    # TODO: trigger change event of orig select does now work properly 
    @$select.trigger('change')
    @$el.text(label)
    
  showDropdown: (e) =>
    view = @dropdownView()
    
    @prompt view 
    
    @_dropdownView.$el.click (e) =>
      @unprompt()
      @_dropdownView = null
    
    view.$el.position
      my: "left top"
      at: "left bottom"
      of: $ @$el