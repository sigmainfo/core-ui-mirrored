class Api::Graph::Property
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  embedded_in :concept

  field :key
  field :value
end
