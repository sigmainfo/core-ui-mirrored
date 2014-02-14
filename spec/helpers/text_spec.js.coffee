#= require spec_helper
#= require helpers/text

describe 'Coreon.Helpers.Text', ->

  beforeEach ->
    @helper = Coreon.Helpers.Text

  describe '#shorten()', ->

    it 'keeps short text unchanged', ->
      @helper.shorten('foo').should.eql 'foo'

    it 'shortens lengthy text', ->
      @helper.shorten('Lorem ipsum dolor sic').should.equal 'Lorem…r sic'

    it 'allows 10 glyphs by default', ->
      @helper.shorten('1234567890').should.equal '1234567890'
      @helper.shorten('12345xxx67890').should.equal '12345…67890'

    it 'takes max length as second argument', ->
      @helper.shorten('12345', 5).should.equal '12345'
      @helper.shorten('123x45', 5).should.equal '123…45'

  describe '#wrap()', ->

    it 'creates an array of strings', ->
      @helper.wrap('foo').should.eql [ 'foo' ]

    it 'word wraps lines after given length', ->
      @helper.wrap('lorem ipsum dolor sic amet', 12).should.eql [ 'lorem ipsum', 'dolor sic', 'amet' ]

    it 'defaults to 24 chars per line', ->
      @helper.wrap('lorem ipsum dolor sic amet').should.eql [ 'lorem ipsum dolor sic', 'amet' ]

    it 'handles leading whitespace correctly', ->
      @helper.wrap(' foo').should.eql [ ' foo' ]
