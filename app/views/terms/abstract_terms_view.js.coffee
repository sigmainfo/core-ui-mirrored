#= require environment
#= require views/composite_view
#= require modules/language_sections

class Coreon.Views.Terms.AbstractTermsView extends Coreon.Views.CompositeView

  className: -> 'terms'

  events: ->
    'click .toggle-all-properties': 'toggleAllProperties'

  initialize: (options = {}) ->
    @app      = options.app or Coreon.application
    @template = options.template

  render: ->
    @$el.html @template languages: @languageSections()
    @renderSubviews()
    @initProperties()
    @

  languageSections: ->
    Coreon.Modules.LanguageSections.languageSections @model.langs()
                                                   , @app.langs()
                                                   , @app.get('langs')

  insertSubview: (subview) ->
    lang = subview.model.get('lang')
    @$("section.language[data-id='#{lang}'] ul").append subview.el

  initProperties: ->
    properties = @$('.properties')
    content = properties.children('div').not('.edit-actions')

    if properties.length is 0
      @$('.toggle-all-properties').hide()
    else
      properties.addClass 'collapsed'
      content.hide()

  toggleAllProperties: ->
    properties = @$('.properties')
    content = properties.children('div').not('.edit-actions')
    collapsed = properties.hasClass 'collapsed'

    properties.toggleClass 'collapsed', not collapsed
    content.slideToggle collapsed
