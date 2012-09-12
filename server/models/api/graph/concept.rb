class Api::Graph::Concept
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  
  embeds_many :properties, class_name: "Api::Graph::Property"
  has_many :terms, dependent: :destroy, autosave: true, class_name: "Api::Graph::Term"
  
  has_and_belongs_to_many :super_concepts, class_name: "Api::Graph::Concept", inverse_of: :sub_concepts
  has_and_belongs_to_many :sub_concepts, class_name: "Api::Graph::Concept", inverse_of: :super_concepts
end
