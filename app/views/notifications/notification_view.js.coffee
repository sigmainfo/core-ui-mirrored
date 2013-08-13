#= require environment
#= require templates/notifications/notification

class Coreon.Views.Notifications.NotificationView extends Backbone.View

  tagName: "li"

  className: "notification"

  template: Coreon.Templates["notifications/notification"]

  events:
    "click a.hide": "close"
  
  initialize: ->
    @listenTo @model, "change", @render
    @listenTo @model, "remove", @hide

  render: ->
    type = @model.get "type"
    @$el.removeClass().addClass "#{@className} #{type}"
    @$el.html @template
      message: @model.get("message")
      label: I18n.t "notification.label.#{type}"
    @
  
  close: ->
    @model.destroy()

  hide: ->
    @$el.slideUp
      duration: "slow"
      step: => @trigger "resize"
      complete: => @remove()

  show: ->
    @$el.slideDown
      duration: "slow"
      step: => @trigger "resize"


    # @model.on "change:hidden", @onChangeHidden, @
  #   @$el.delay(5000).slideUp()

  # render: ->
  #   type = @model.get "type"
  #   @$el.html @template message: @model.get("message"), url: "/notification/hide", label: I18n.t "notification.label.#{type}"
  #   @$el.addClass type
  #   @$el.hide() if @model.get "hidden"
  #   @
  # 
  # hide: (event) ->
  #   event.preventDefault()
  #   event.stopPropagation()
  #   @model.set "hidden", true 

  # onChangeHidden: ->
  #   @$el.stop()
  #   [type, duration] =
  #     if @model.get "hidden"
  #       ["hide", "fast"]
  #     else
  #       ["show", 400]
  #   @$el.animate {
  #     height: type
  #   },
  #     duration: duration
  #     step: @onStep

  # onStep: =>
  #   @$el.trigger "animate"
