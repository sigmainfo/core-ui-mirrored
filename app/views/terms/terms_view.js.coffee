#= require environment
#= require helpers/render
#= require templates/terms/terms
#= require templates/shared/info
#= require templates/properties/properties
#= require templates/properties/property

class Coreon.Views.Terms.TermsView extends Backbone.View

  className: 'terms'

  template: Coreon.Templates['terms/terms']

  initialize: (options = {}) ->
    options.app ?= Coreon.application
    @app = options.app

  render: ->
    langs = @app.langs()
    selected = @app.get('langs')

    terms = @model.byLang(langs...).filter (group) ->
        group.terms.length > 0 or group.id in selected

    hasProperties = @model.any (term) ->
      term.propertiesByKey(precedence: langs).length > 0

    @$el.html @template
      langs: langs
      terms: terms
      hasProperties: hasProperties

    @$('section.properties')
      .addClass('collapsed')

      .children('div')
        .css('display', 'none')

        .find('td>ul')
          .find('li:first')
          .addClass('selected')

    @
