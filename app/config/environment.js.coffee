#= require jquery
#= require underscore
#= require backbone
#= require hamlcoffee
#= require i18n
#= require i18n/translations
#= require namespace
#= require modules/messages

HAML.globals = -> Coreon.Helpers

_(Backbone.Model::).extend Coreon.Modules.Messages
