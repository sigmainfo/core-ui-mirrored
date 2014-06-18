#= require environment
#= require modules/helpers
#= require modules/prompt
#= require jquery.ui.position
#= require lib/select_popup

$ = jQuery

$.fn.extend
  coreonSelect: (options) ->
    this.each (input_field) ->
      $this = $ this
      coreonSelect = $this.data('coreonSelect')
      if options is 'destroy' && coreonSelect
        coreonSelect.destroy()
      else unless coreonSelect
        $this.data('coreonSelect', new Coreon.Lib.Select($this, options))

      return


class Coreon.Lib.Select

  Coreon.Modules.include @, Coreon.Modules.Prompt

  constructor: (@$select, @options={}) ->
    @$el = $ "<div class='coreon-select'>"
    @$el.attr 'title', @$select.attr('title')
    @render()

  render: ->
    @_buildSelectOptions()
    selected = $("option[value=#{@$select.val()}]", @$select).first()
    selected = $("option", @$select).first() if selected.length == 0

    @$el.text selected.text()
    @$el.attr('data-select-name', @$select.attr('name'))
    @$el.addClass(@$select.attr('class'))

    if @selectOptions.length < 2
      @$el.addClass('single')
    else
      @$el.click @showDropdown

    @$select.hide().after @$el
    @

  _buildSelectOptions: ->
    selectOptions = []

    $('option', @$select).each (i) ->
      $option = $ this
      selectOptions.push [$option.val(), $option.text()]

    @selectOptions = selectOptions

  changeTo: (val, label) =>
    @$el.text(label)
    @$select.val(val).change()
    @

  showDropdown: (e) =>
    view = new Coreon.Lib.SelectPopup
      widget: @
      value: @$select.val()
      selectOptions: @selectOptions
      widgetClasses: @$select.attr('class')

    @prompt view

    view.$('ul').position
      my: "left top"
      at: "left bottom"
      of: $ @$el

    @
