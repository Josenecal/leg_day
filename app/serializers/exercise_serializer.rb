class ExerciseSerializer
  include JSONAPI::Serializer

  attributes(
    :name,
    :category,
    :equipment,
    :level,
    :mechanic,
    :force,
    :primary_muscles,
    :secondary_muscles,
    :instructions
  )
end
