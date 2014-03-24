#= require environment
#= require helpers/action_for
#= require jquery.ui.resizable

class Coreon.Views.Panels.PanelView extends Backbone.View

  className: 'panel'

  delegateEvents: ->
    super
    @$el.on 'click.delegateEvents'
          , '.actions .maximize'
          , _(@switchToMax).bind @


  initialize: (options = {}) ->
    @panel = options.panel

    @stopListening()

    @listenTo @panel
            , 'change:width change:height'
            , @resize

    @listenTo @panel
            , 'change:widget'
            , @updateMode

  widgetize: ->
    @$el
      .addClass('widget')
      .resizable
        handles: 's, sw, w'
        minWidth: 240
        minHeight: 80
        start: (event, ui) =>
          @resizeStart ui
        resize: (event, ui) =>
          @resizeStep ui
        stop: (event, ui) =>
          @resizeStop ui

    if @$('.titlebar .actions a.maximize').length is 0
      @$('.titlebar .actions').append Coreon.Helpers.action_for('panel.maximize')

    @resize()

    @

  maximize: ->
    @$el.removeClass('widget')

    @$el.resizable 'destroy' if @$el.hasClass 'ui-resizable'

    @$('.actions a.maximize').remove()

    @resize()

    @

  resize: ->
    if @panel.get('widget')
      @$el
        .css
          left: 0
          width: @panel.get('width')
          height: @panel.get('height')
    else
      @$el.css
        width: 'auto'
        height: 'auto'

  switchToMax: (event) ->
    event.preventDefault()
    @panel.set 'widget', no

  updateMode: (model, value) ->
    if value
      @widgetize()
    else
      @maximize()

  resizeStart: (ui) ->

  resizeStep: (ui) ->
    @panel.set ui.size

  resizeStop: (ui) ->
