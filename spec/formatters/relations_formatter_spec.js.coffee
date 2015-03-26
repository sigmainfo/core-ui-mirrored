#= require spec_helper
#= require formatters/relations_formatter

describe "Coreon.Formatters.RelationsFormatter", ->

  relationTypes = null
  model = null
  edges_in = null
  edges_out = null
  formatter = null

  beforeEach ->
    relationTypes = [
      {key: 'see also', type: 'associative', icon: 'see-also'},
      {key: 'antonymic', type: 'associative', icon: 'antonymic'},
      {key: 'parent of', type: 'hierarchical', icon: 'parent-of'},
    ]
    Coreon.Models.RepositorySettings = sinon.stub
    Coreon.Models.RepositorySettings.relationTypes = -> relationTypes
    edges_in = []
    edges_out = []
    formatter = new Coreon.Formatters.RelationsFormatter(
      relationTypes,
      edges_in,
      edges_out
    )

  describe "#associativeRelations()", ->

    it "groups model's relations by key", ->
      relations = formatter.associativeRelations()
      expect(relations).to.have.lengthOf 2

    it "accumulates model's relations", ->
      edges_out.push {edge_type: 'see also', source_node_id: '1', target_node_id: '2' }
      edges_out.push {edge_type: 'other', source_node_id: '1', target_node_id: '88' }
      edges_in.push {edge_type: 'see also', source_node_id: '5', target_node_id: '1' }
      edges_in.push {edge_type: 'antonymic', source_node_id: '5', target_node_id: '1' }
      relations = formatter.associativeRelations()
      expect(relations).to.have.lengthOf 2
      seeAlso = relations.filter( (r) -> r.relationType.key == 'see also' )[0]
      expect(seeAlso.relations).to.have.lengthOf 2
      antonymic = relations.filter( (r) -> r.relationType.key == 'antonymic' )[0]
      expect(antonymic.relations).to.have.lengthOf 1
      parentOf = relations.filter( (r) -> r.relationType.key == 'parent of' )[0]
      expect(parentOf).to.eql undefined
      other = relations.filter( (r) -> r.relationType.key == 'other' )[0]
      expect(other).to.eql undefined




