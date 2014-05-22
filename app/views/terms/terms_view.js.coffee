#= require environment
#= require helpers/render
#= require templates/terms/terms
#= require views/terms/term_view
#= require modules/language_sections

class Coreon.Views.Terms.TermsView extends Backbone.View

  _(@::).extend Coreon.Modules.LanguageSections

  className: 'terms show'

  events:
    'click .toggle-all-properties': 'toggleAllProperties'

  initialize: (options = {}) ->
    _(options).defaults
      app: Coreon.application
      template: Coreon.Templates['terms/terms']

    @app = options.app
    @template = options.template
    @subviews = []

  render: ->
    _(@subviews).invoke 'remove'
    @subviews = []

    languages = @langs @model.langs(), @app.langs(), @app.get('langs')

    @$el.html @template languages: languages

    @model.forEach (term) =>
      termView = new Coreon.Views.Terms.TermView
        model: term
      termView.render()
      @$(".language[data-id='#{term.get 'lang'}'] ul")
        .append termView.$el
      @subviews.push termView

    @$('.properties')
      .addClass('collapsed')
      .children('div').not('.edit')
        .hide()

    hasTermProperties = _(@model.models).any (term) ->
      term.get('properties').length > 0
    unless hasTermProperties
      @$('.toggle-all-properties').hide()

    @

  toggleAllProperties: (event) =>
    event.stopPropagation()
    event.preventDefault()

    properties = @$ '.properties'

    if properties.filter('.collapsed').length is 0
      properties
        .addClass('collapsed')

        .children('div').not('.edit')
          .slideUp()
    else
      properties
        .removeClass('collapsed')

        .children('div').not('.edit')
          .slideDown()
