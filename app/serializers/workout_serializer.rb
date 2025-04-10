class WorkoutSerializer
  include JSONAPI::Serializer
  has_many :set_structures
  attribute :completed_at do |w|
    w.created_at.strftime("%A, %m/%d/%Y, %I:%M%p")
  end

end
