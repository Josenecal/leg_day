class ExerciseSerializer
  include JSONAPI::Serializer

  has_many :set_structures
  has_many :workouts
  attributes :name, :description
end
