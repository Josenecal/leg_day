require 'rails_helper'
require 'pry'

RSpec.describe "/api/v1/exercises", type: :request do
    let! (:user) { create :user }
    let! (:required_headers) {
            {
                content_type: "application/json",
                accept: "application/json",
                authorization: "#{user.id}"
            }
        }

    context "GET /" do
        context "authorization" do
            it "responds 401 if auth is missing" do
                unauthorized_headers = required_headers.reject! { |k, v| k == :authorization }
                
                get "/api/v1/workouts", headers: unauthorized_headers
                expect(response.status.to_i).to eq 401
            end

            it "responds 401 if auth references a non-existant user" do
                bad_user_auth = required_headers.merge(authorization: "0")
                
                get "/api/v1/workouts", headers: bad_user_auth
                expect(response.status.to_i).to eq 401
            end

            it "responds 200 if auth references an existing user" do
                get "/api/v1/workouts", headers: required_headers
                expect(response.status.to_i).to eq 200
            end
        end

        context "response" do
            let! (:workout_1) { create :workout, user: user }
            let! (:workout_2) { create :workout, user: user }

            let! (:set_structure_1_1) { create :set_structure, workout: workout_1 }
            let! (:set_structure_1_2) { create :set_structure, workout: workout_1 }
            let! (:set_structure_2_1) { create :set_structure, workout: workout_2 }

            before { get "/api/v1/workouts", headers: required_headers }

            it "should contain a serialized list of a user's workouts" do
                workouts = JSON.parse(response.body)["data"]

                # Response should contain 2 workouts from above
                expect(workouts.count).to eq 2

                # Verify the serialized objects are the 2 workouts
                workouts.each do |workout|
                    expect(workout["type"]).to eq "workout"
                end
            end

            it "should include appropriate relationships" do
                # First Workout should contain set structures 1_1 and 1_2
                sent_workout_1 = JSON.parse(response.body)["data"].first

                # Verify isolated workout is workout_1
                expect(sent_workout_1["id"]).to eq workout_1.id.to_s

                # Should contain 2 relationships, "set_structures" and "exercises"
                expect(sent_workout_1["relationships"].keys.sort).to eq ["exercises", "set_structures"]

                # Set Structures should have IDs matching set_structure_1_1 and set_structure_1_2
                wkt_1_set_structs = sent_workout_1["relationships"]["set_structures"]["data"]
                expected_ss_ids = (wkt_1_set_structs.reduce([]) {|acc, ss| acc << ss["id"].to_i }).sort
                actual_ss_ids = [set_structure_1_1.id, set_structure_1_2.id].sort

                expect(expected_ss_ids).to eq actual_ss_ids

                # Exercises should also have expected IDs
                wkt_1_exercises = sent_workout_1["relationships"]["exercises"]["data"]
                expected_e_ids = (wkt_1_exercises.reduce([]) {|acc, e| acc << e["id"].to_i }).sort
                actual_e_ids = [set_structure_1_1.exercise_id, set_structure_1_2.exercise_id].sort

                expect(expected_e_ids).to eq actual_e_ids
            end

            it "only includes a user's owned workouts" do
                # Ensure workout exists associated to another user
                someone_elses_wrkt = create(:workout)
                expect(someone_elses_wrkt.user_id).not_to eq user.id

                # Get index of user's workouts again, post new workout creation
                get "/api/v1/workouts", headers: required_headers
                returned_wrkts = JSON.parse(response.body)["data"]
                returned_wrkt_ids = returned_wrkts.reduce([]) { |acc, w| acc << w["id"].to_i }

                # Returned workout IDs should be as expected and not include new workout ID
                expect(returned_wrkt_ids.include?(workout_1.id)).to be true
                expect(returned_wrkt_ids.include?(workout_2.id)).to be true
                expect(returned_wrkt_ids.include?(someone_elses_wrkt.id)).to be false
            end
        end
    end

    context "GET /:id" do
        let! (:workout_1) { create :workout, user: user }
        let! (:workout_2) { create :workout, user: user }

        let! (:set_structure_1_1) { create :set_structure, workout: workout_1 }
        let! (:set_structure_1_2) { create :set_structure, workout: workout_1 }
        let! (:set_structure_2_1) { create :set_structure, workout: workout_2 }

        context "authorization" do
            it "responds 401 if auth is missing" do
                unauthorized_headers = required_headers.reject! { |k, v| k == :authorization }
                
                get "/api/v1/workouts/#{workout_1.id}", headers: unauthorized_headers
                expect(response.status.to_i).to eq 401
            end

            it "responds 401 if auth references a non-existant user" do
                bad_user_auth = required_headers.merge(authorization: "0")
                
                get "/api/v1/workouts/#{workout_1.id}", headers: bad_user_auth
                expect(response.status.to_i).to eq 401
            end

            it "responds 401 if requesting a workout not belonging to a user" do
                someone_elses_wrkt = create(:workout)
                get "/api/v1/workouts/#{someone_elses_wrkt.id}", headers: required_headers
                expect(response.status.to_i).to eq 401
            end

            it "responds 200 if auth references an existing user" do
                get "/api/v1/workouts", headers: required_headers
                expect(response.status.to_i).to eq 200
            end
        end

        context "response" do

            before { get "/api/v1/workouts/#{workout_1.id}", headers: required_headers }

            it "should contain a single workout" do
                workout = JSON.parse(response.body)

                # Response should contain workout_1, hashed
                expect(workout.is_a?(Hash)).to eq true
                expect(workout["type"]).to eq "workout"
                expect(workout["id"].to_i).to eq workout_1.id
            end

            it "should include appropriate relationships" do
                # First Workout should contain set structures 1_1 and 1_2
                workout = JSON.parse(response.body)

                # Should contain 2 relationships, "set_structures" and "exercises"
                expect(workout["relationships"].keys.sort).to eq ["exercises", "set_structures"]

                # Set Structures should have IDs matching set_structure_1_1 and set_structure_1_2
                wrkt_set_structs = workout["relationships"]["set_structures"]["data"]
                expected_ss_ids = (wrkt_set_structs.reduce([]) {|acc, ss| acc << ss["id"].to_i }).sort
                actual_ss_ids = [set_structure_1_1.id, set_structure_1_2.id].sort

                expect(expected_ss_ids).to eq actual_ss_ids

                # Exercises should also have expected IDs
                wrkt_exercises = workout["relationships"]["exercises"]["data"]
                expected_e_ids = (wrkt_exercises.reduce([]) {|acc, e| acc << e["id"].to_i }).sort
                actual_e_ids = [set_structure_1_1.exercise_id, set_structure_1_2.exercise_id].sort

                expect(expected_e_ids).to eq actual_e_ids
            end
        end
    end

    context "POST /" do

    end

    context "PATCH /:id" do

    end

    context "DELETE /:id" do

    end
end