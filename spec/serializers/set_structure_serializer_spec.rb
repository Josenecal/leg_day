require 'rails_helper'
require 'pry'

RSpec.describe WorkoutSerializer do
    let! (:exercise) {
        Exercise.create(
            name: "squat",
            description: "thighs parallel to the ground",
            muscle_groups: ["thighs","core","back"],
            equipment: ["bar", "plate weights", "squat rack"],
            discipline: "Weight Training",
            category: 0
        )
    }
    let! (:workout) {
        Workout.create(
            user_id: user.id,
            created_at: DateTime.new(1970,02,25,20,00)
        )
    }
    let! (:set_structure) {
        SetStructure.create(
            workout_id: workout.id,
            exercise_id: exercise.id,
            sets: 3,
            reps: 12,
            resistance: 150
            resistance_units: 
        )
    }
    context "serializable_hash data shape" do
        it "should serialize data into the expected JSON format" do
            expected = {
                data: {
                    id: "#{workout.id}",
                    type: :workout,
                    attributes: {
                        id: workout.id,
                        completed_at: "Wednesday, 02/25/1970, 08:00PM" #matches workout's created_at
                    },
                    relationships: {
                        set_structures: {
                            data: []
                        },
                        exercises: {
                            data: []
                        }
                    }
                }
            }
            actual = WorkoutSerializer.new(workout).serializable_hash

            expect(expected).to eq actual
        end
    end
end