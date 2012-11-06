class Api::Graph::Taxonomy
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :name
  
  has_many :nodes, dependent: :destroy, autosave: true, class_name: "Api::Graph::TaxonomyNode"
end
