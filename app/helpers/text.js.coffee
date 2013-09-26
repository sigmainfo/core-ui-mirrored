#= require environment
#

Coreon.Helpers.Text =

  shorten: (text = "", max = 10) ->
    text = text[0..max - 2] + "…" if text.length > max
    text

  wrap: (text = "", length = 24) ->
    lines = []
    words = text.split /\s+/
    while word = words.shift()
      if lines.length > 0 and lines[lines.length - 1].length + word.length < length
        lines[lines.length - 1] += " #{word}"
      else
        line = word
        lines.push line
    lines
