#= require environment
#

Coreon.Helpers.Text =

  shorten: (text = "", max = 10) ->
    text = text[0..max - 2] + "…" if text.length > max
    text
