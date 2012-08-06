#= require environment

Coreon.Helpers.link_to = (label, href, attributes = {}) ->
  href ?= label
  root = Coreon.application?.options.root or "/"
  href = root + href unless href.match /^[a-z]+:\/\//
  attributes.href = href
  $("<div>").append($("<a>", attributes).html(label)).html()
