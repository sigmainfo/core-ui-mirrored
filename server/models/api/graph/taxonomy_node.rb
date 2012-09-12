class Api::Graph::TaxonomyNode
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :name
  
  belongs_to :taxonomy, autosave: true, class_name: "Api::Graph::Taxonomy"

  has_and_belongs_to_many :super_nodes, class_name: "Api::Graph::TaxonomyNode", inverse_of: :sub_nodes
  has_and_belongs_to_many :sub_nodes, class_name: "Api::Graph::TaxonomyNode", inverse_of: :super_nodes
end
