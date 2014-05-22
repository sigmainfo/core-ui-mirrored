#= require environment
#= require modules/language_sections

describe 'Coreon.Modules.LanguageSections', ->

  module = Coreon.Modules.LanguageSections

  context '#langs()', ->

    ids = (langs) ->
      _(langs).pluck 'id'

    it 'creates language sections from used langs', ->
      langs = module.langs ['de']
      expect(langs).to.eql [id: 'de', className: 'de', empty: no]

    it 'unifies class name', ->
      langs = module.langs ['DE-AT']
      expect(langs).to.eql [id: 'DE-AT', className: 'de', empty: no]

    it 'sorts language sections by available language order', ->
      langs = module.langs ['hu', 'de', 'fr'], ['de', 'fr', 'hu']
      expect(ids langs).eql ['de', 'fr', 'hu']

    it 'appends language sections for unknown languages', ->
      langs = module.langs ['hu', 'el', 'de', 'fr'], ['de', 'fr', 'hu']
      expect(ids langs).eql ['de', 'fr', 'hu', 'el']

    it 'skips unused languages', ->
      langs = module.langs ['fr', 'de'], ['de', 'fr', 'hu']
      expect(ids langs).eql ['de', 'fr']

    it 'sorts selected languages upfront', ->
      langs = module.langs ['fr', 'hu', 'de'], ['de', 'fr', 'hu'], ['hu']
      expect(ids langs).eql ['hu', 'de', 'fr']

    it 'creates empty sections for unused selected languages', ->
      langs = module.langs ['fr', 'de'], ['de', 'fr', 'hu'], ['hu']
      first = langs[0]
      expect(first).to.eql {id: 'hu', className: 'hu', empty: yes}
