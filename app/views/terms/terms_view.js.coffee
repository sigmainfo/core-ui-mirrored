#= require environment
#= require helpers/render
#= require templates/terms/terms
#= require views/terms/term_view

class Coreon.Views.Terms.TermsView extends Backbone.View

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

    selectedLangs  = @app.get('langs')
    availableLangs = @app.langs()
    usedLangs      = @model.langs()

    presentLangs = _.intersection availableLangs, usedLangs
    emptyLangs   = _.difference selectedLangs, presentLangs
    langs        = _.union selectedLangs, presentLangs, usedLangs

    languages = langs.map (lang) ->
      id: lang
      className: lang[0..1].toLowerCase()
      empty: lang in emptyLangs

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
