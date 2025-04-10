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
    let! (:workout) {
        Workout.create(
            user_id: user.id,
            created_at: DateTime.new(1970,02,25,20,00)
        )
    }
    context "serializable_hash data shape" do
        it "should serialize data into the expected JSON format" do
            expected = {
                data: {
                    id: "#{workout.id}",
                    type: :workout,
                    attributes: {
                        completed_at: "Wednesday, 02/25/1970, 08:00PM" #matches workout's created_at
                    },
                    relationships: {
                        set_structures: {
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