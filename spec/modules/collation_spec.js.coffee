#= require spec_helper
#= require modules/collation

describe 'Coreon.Modules.Collation', ->

  describe '#sortByLabel()', ->

    sortBy = Coreon.Modules.Collation.sortBy

    it 'sorts list by label attribute', ->
      list = ['b', 'a', 'c'].map (label) ->
        new Backbone.Model label: label
      result = sortBy 'label', list
      labels = result.map (model) -> model.get('label')
      expect(labels).to.eql ['a', 'b', 'c']

    it 'sorts case insensitive', ->
      list = ['B', 'a', 'c'].map (label) ->
        new Backbone.Model label: label
      result = sortBy 'label', list
      labels = result.map (model) -> model.get('label')
      expect(labels).to.eql ['a', 'B', 'c']

    it 'returns a copy of the list', ->
      list = []
      result = sortBy 'label', list
      expect(result).to.not.equal list

    it 'defaults to sorting itself when used as mixin', ->
      list = ['b', 'a', 'c'].map (label) ->
        new Backbone.Model label: label
      list.sortBy = sortBy
      result = list.sortBy 'label'
      labels = result.map (model) -> model.get('label')
      expect(labels).to.eql ['a', 'b', 'c']
