#= require environment
#= require templates/helpers/link_to

Coreon.Helpers.link_to = (label, href) ->
  href ?= label
  root = Coreon.application?.options.root or "/"
  href = root + href unless href.match /^[a-z]+:\/\//
  Coreon.Templates["helpers/link_to"] label: label, href: href
