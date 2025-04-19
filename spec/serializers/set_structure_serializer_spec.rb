require 'rails_helper'
require 'pry'

RSpec.describe WorkoutSerializer do
    let! (:user) { create :user }
    let! (:exercise) { create :exercise }
    let! (:workout) { create :workout, user_id: user.id, created_at: DateTime.new(1970,02,25,20,00) }
    let! (:set_structure) { create :set_structure, workout_id: workout.id, exercise_id: exercise.id }
    
    context "serializable_hash data shape" do
        it "should serialize data into the expected JSON format" do
            actual = SetStructureSerializer.new(set_structure).serializable_hash
            expected = {
                data: {
                    id: "#{set_structure.id}",
                    type: :set_structure,
                    attributes: {
                        sets: set_structure.sets,
                        reps: set_structure.reps,
                        name: exercise.name,
                        resistance: "#{set_structure.resistance} #{set_structure.resistance_unit}"
                    }
                }
            }

            expect(actual).to eq expected
        end
    end
end