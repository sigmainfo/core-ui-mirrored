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
    @collapseAllProperties()
    @

  languageSections: ->
    Coreon.Modules.LanguageSections.languageSections @model.langs()
                                                   , @app.langs()
                                                   , @app.get('langs')

  insertSubview: (subview) ->
    lang = subview.model.get('lang')
    @$("section.language[data-id='#{lang}']").append subview.el

  collapseAllProperties: ->
    properties = @$('.properties')
    content = properties.children('div').not('.edit')

    properties.addClass 'collapsed'
    content.hide()

  toggleAllProperties: ->
    properties = @$('.properties')
    content = properties.children('div').not('.edit')
    collapsed = properties.hasClass 'collapsed'

    properties.toggleClass 'collapsed', not collapsed
    content.slideToggle collapsed
