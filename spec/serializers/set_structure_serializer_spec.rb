require 'rails_helper'
require 'pry'

RSpec.describe WorkoutSerializer do
    let! (:user) {
        User.create(
            first_name: "Leopold",
            last_name: "Loggle",
            email: "loggle@wartwoodgeneral.com",
            password: "G41N5"
        )
    }
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
            resistance: 150,
            resistance_unit: 0
        )
    }
    context "serializable_hash data shape" do
        it "should serialize data into the expected JSON format" do
            expected = {
                data: {
                    id: "#{set_structure.id}",
                    type: :set_structure,
                    attributes: {
                        sets: set_structure.sets,
                        reps: set_structure.reps,
                        name: exercise.name,
                        resistance: "#{set_structure.resistance} lbs"
                    }
                }
            }
            actual = SetStructureSerializer.new(set_structure).serializable_hash

            expect(expected).to eq actual
        end
    end
end