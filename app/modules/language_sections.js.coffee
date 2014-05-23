#= require environment

Coreon.Modules.LanguageSections =

  languageSections: (used, available = [], selected = []) ->
    present = _.intersection available, used
    empty = _.difference selected, present

    _.union(selected, present, used).map (lang) ->
      id: lang
      className: lang[0..1].toLowerCase()
      empty: lang in empty
