#= require 'environment'

children = (section) ->
  section.children().not('h3')

Coreon.Modules.CollapsableSections =

  sectionHeading: '*:first-child'

  findSection: (name) ->
    @$ "section.#{name}"

  collapsedSections: ->
    @_collapsedSections ?= []

  collapseSection: (name, options) ->
    collapsed = @collapsedSections()
    collapsed.push name unless name in collapsed
    @findSection(name)
      .addClass('collapsed')
      .children().not(@sectionHeading)
        .slideUp options

  expandSection: (name, options) ->
    collapsed = @collapsedSections()
    index = collapsed.indexOf name
    collapsed.splice(index, 1) unless index < 0
    @findSection(name)
      .removeClass('collapsed')
      .children().not(@sectionHeading)
        .slideDown options

  toggleSection: (name, options) ->
    if name in @collapsedSections()
      @expandSection name, options
    else
      @collapseSection name, options

  restoreCollapsedSections: ->
    @collapsedSections().forEach (name) =>
      @collapseSection name, duration: 0
