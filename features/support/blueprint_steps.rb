require_relative 'resources'

module BlueprintSteps
  include Spinach::DSL
  include Resources

  step 'the repository defines an empty blueprint for concepts' do
    blueprint(:concept)['clear'].delete
  end

  step 'the repository defines an empty blueprint for terms' do
    blueprint(:term)['clear'].delete
  end
end
