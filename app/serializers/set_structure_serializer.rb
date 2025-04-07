class SetStructureSerializer
  include JSONAPI::Serializer
  
  belongs_to :workout
  belongs_to :exercise

  attributes :sets, :reps

  attribute :name do |set|
    set.exercise.name
  end

  attribute :resistance do |set|
    "#{set.resistance} #{set.resistance_unit}"
  end
end
