require 'rails_helper'
require 'pry'

RSpec.describe ExerciseSerializer do
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
    context "serializable_hash data shape" do
        it "should serialize data into the expected JSON format" do
            expected = {
                data: {
                    id: "#{exercise.id}",
                    type: :exercise,
                    attributes: {
                        name: "#{exercise.name}",
                        description: "#{exercise.description}"
                    },
                    relationships: {
                        set_structures: {
                            data: []
                        },
                        workouts: {
                            data: []
                        }
                    }
                }
            }
            actual = ExerciseSerializer.new(exercise).serializable_hash

            expect(expected).to eq actual
        end
    end
end