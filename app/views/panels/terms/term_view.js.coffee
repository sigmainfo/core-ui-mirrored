#= require environment
#= require helpers/can
#= require helpers/render
#= require templates/terms/_term
#= require templates/concepts/_info
#= require modules/helpers
#= require modules/confirmation

class Coreon.Views.Panels.Terms.TermView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Confirmation

  tagName: 'li'

  className: 'term'

  template: Coreon.Templates['terms/term']

  events:
    "click .remove-term": "removeTerm"

  render: ->
    collapsed = if Coreon.application.repositorySettings().get('propertiesCollapsed') == false then false else true
    @$el.html @template term: @model, collapsed: collapsed
    @

  removeTerm: (evt) ->
    trigger = $ evt.target
    @confirm
      trigger: trigger
      container: @$el
      message: I18n.t "term.confirm_delete"
      action: =>
        value = @model.get "value"
        @model.destroy
          success: =>
            @model.trigger 'termChanged'
            Coreon.Models.Notification.info I18n.t("notifications.term.deleted", value: value)