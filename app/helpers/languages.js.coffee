#= require environment

Coreon.Helpers.languageOptions = (codesArray) ->
  _(codesArray).map (lang) ->
      {value: lang, label: I18n.t("languages.#{lang}")}