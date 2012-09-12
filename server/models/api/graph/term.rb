class Api::Graph::Term
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :lang
  field :value

  belongs_to :concept
end
